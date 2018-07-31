static class BeatInfo {
  boolean beat;
  int beatNumber;
}

// The system travels down these modes as it downgrades over time.
// The last one needs to be suitable if the beats mismatch and if
// the beat number is untrustworthy.
static enum BeatMode {
  EVERY_BEAT(true, true), EVERY_TWO_BEATS(true, false), EVERY_FOUR_BEATS(false, false), NONE(true, true);

  public final boolean suitableIfBeatsMismatch;
  public final boolean suitableIfBeatNumberUntrustworthy;

  private BeatMode(boolean suitableIfBeatsMismatch, boolean suitableIfBeatNumberUntrustworthy) {
    this.suitableIfBeatsMismatch = suitableIfBeatsMismatch;
    this.suitableIfBeatNumberUntrustworthy = suitableIfBeatNumberUntrustworthy;
  }
}

// All of the access of these variables have to be synchronized,
// because the beat-link library is crazy and has tons of thread.
static class BeatController {
  public static int kBarsBeforeBeatDowngrade = 32;

  boolean beatSignal = false;
  int beatSignalNumber = 0;

  DownBeatOffDetector somethingOffDetector = new DownBeatOffDetector();
  BeatMode mode = BeatMode.NONE;
  int barsInThisMode = 0;
  boolean beatsMismatched = false;
  boolean beatNumberUntrustworty = false;
  int beatsSinceUntrustworthy = 0;
  
  boolean armed = false;
  BeatMode nextMode = BeatMode.NONE;
  
  synchronized BeatMode getMode() {
    return mode;
  }
  synchronized int getBarsInMode() {
    return barsInThisMode;
  }

  synchronized void armMode(BeatMode mode) {
    nextMode = mode;
    armed = true;
  }

  synchronized BeatInfo consumeBeat() {
    BeatInfo info = new BeatInfo();
    info.beat = beatSignal;
    info.beatNumber = beatSignalNumber;
    beatSignal = false;
    return info;
  }

  synchronized void onMasterChanged(DeviceUpdate update) {
  }

  synchronized void onBeat(Beat beat) {
    if (somethingOffDetector.isSynchronizedAndBeatNumbersOff(beat)) {
      onBeatMismatchDetected();
    }
    if (beat.isTempoMaster()) {
      if (!beat.isBeatWithinBarMeaningful()) {
        onBeatNumberUntrustworty();
      } else {
        if (beatNumberUntrustworty) {
          println("Beat number now considered trustworthy");
        }
        beatNumberUntrustworty = false;
        beatsSinceUntrustworthy = 0;
      }
      int beatWithinBar = 0;
      if (beatNumberUntrustworty) {
        beatWithinBar = (beatsSinceUntrustworthy % 4) + 1;
      } else {
        beatWithinBar = beat.getBeatWithinBar();
      }
      if (beatWithinBar == 1) {
        onBar();
      }
      boolean signalBeat = false;
      switch(mode) {
      case EVERY_BEAT: 
        signalBeat = true;
        break;
      case EVERY_TWO_BEATS:
        signalBeat = beatWithinBar == 2 || beatWithinBar == 4;
        break;
      case EVERY_FOUR_BEATS:
        signalBeat = beatWithinBar == 1;
      case NONE:
        break;
      }
      if (signalBeat) {
        beatSignal = true;
        beatSignalNumber = beatWithinBar;
      }
    }
  }

  // Called every time the DownBeatOffDetector detects mismatched
  // beats that are synchronized.
  void onBeatMismatchDetected() {
    if (!beatsMismatched) {
      println("Mismatch detected");
      beatsMismatched = true;
      if (mode.suitableIfBeatsMismatch)
        return;
      BeatMode newMode = mode;
      for (int i = mode.ordinal() + 1; i < BeatMode.values().length; ++i) {
        mode = BeatMode.values()[i];
        if (newMode.suitableIfBeatsMismatch) {
          break;
        }
      }
      mode = newMode;
    }
  }

  // Called every time the master beat is untrustworthy.
  void onBeatNumberUntrustworty() {
    if (!beatNumberUntrustworty) {
      println("Untrustworthy beat numbers detected");
      beatNumberUntrustworty = true;
      beatsSinceUntrustworthy = 0;
      if (mode.suitableIfBeatNumberUntrustworthy)
        return;
      BeatMode newMode = mode;
      for (int i = mode.ordinal() + 1; i < BeatMode.values().length; ++i) {
        mode = BeatMode.values()[i];
        if (newMode.suitableIfBeatNumberUntrustworthy) {
          break;
        }
      }
      mode = newMode;
    } else {
      beatsSinceUntrustworthy++;
    }
  }

  void onBar() {
    if (armed) {
      mode = nextMode;
      nextMode = null;
      armed = false;
      barsInThisMode = 0;
      beatsMismatched = false;
    }
    if (barsInThisMode >= kBarsBeforeBeatDowngrade) {
      barsInThisMode = 0;
      BeatMode newMode = mode;
      for (int i = mode.ordinal() + 1; i < BeatMode.values().length; ++i) {
        newMode = BeatMode.values()[i];
        // Only stop when the mode works with our state.
        if ((!beatsMismatched || newMode.suitableIfBeatsMismatch)
          && (!beatNumberUntrustworty || newMode.suitableIfBeatNumberUntrustworthy)) {
          break;
        }
      }
      println("Downgrading from mode " + mode + " to " + newMode);
      mode = newMode;
    }
    ++barsInThisMode;
  }
}

// This class tries to detect if we have an 'off' downbeat (during song
// synchronization, the downbeat is different between the two songs). If
// this is the case, then this will 
static class DownBeatOffDetector {
  static final float kBPMEpsiloneSameBeat = 0.05f;
  static final float kBPMEpsiloneSameBpm = 0.01f;
  Beat lastBeat = null;

  boolean isSynchronizedAndBeatNumbersOff(Beat b) {
    if (lastBeat == null) {
      lastBeat = b;
      return false;
    }
    // Only consider beats that are about the same BPM,
    // and at the same time.
    float bpm = b.getBpm() * 1f / 100;
    float lastBpm = lastBeat.getBpm() * 1f / 100;
    if (abs(bpm-lastBpm) / lastBpm > kBPMEpsiloneSameBpm) {
      lastBeat = b;
      return false;
    }
    float millisPerBeat = 60 * 1000 / bpm;
    float millisEpsilon = (b.getTimestamp() / 1000000) - (lastBeat.getTimestamp() / 1000000);
    if (millisEpsilon > millisPerBeat * kBPMEpsiloneSameBeat) {
      lastBeat = b;
      return false;
    }

    // We are synchronized!
    boolean result = lastBeat.getBeatWithinBar() != b.getBeatWithinBar();
    lastBeat = b;
    return result;
  }
}
