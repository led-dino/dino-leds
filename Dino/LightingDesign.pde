abstract class LightingDesign {
  // Called once, first, with the model to be designed.
  abstract void init(Model m);
  // Called to update movement etc, repeatedly per frame
  abstract void update(long millis);

  // Called when this design is getting transitioned to
  void onCycleStart() {
  }

  void onBeat() {
  }

  boolean supportsEyeColors() { 
    return false;
  }
  boolean supportsNoseColors() { 
    return false;
  }
  boolean supportsMouthColors() { 
    return false;
  }

  // Called to get color in current state - can be called before update().
  abstract color getColor(int stripNum, int ledNum, Vec3 position, ModelLineType lineType);

  color getEyeColor() { 
    return #ffffff;
  }
  color getNoseColor() { 
    return #ffffff;
  }
  color getMouthColor() { 
    return #ffffff;
  }
}
