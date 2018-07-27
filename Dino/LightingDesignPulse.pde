class Pulse implements LightingDesign {
  final int kSecondsPerCycle = 10;
  
  color currentColor;
  color nextColor;
  color blackColor;
  // from 0 to 2, taking into account black in between.
  float lerpValue = 0;

  Pulse() {
  }

  void init(Model m) {
    colorMode(HSB, 100);
    currentColor = randomAccentColorWhiter();
    nextColor = randomAccentColorWhiter();
    blackColor = lerpColor(currentColor, nextColor, 0.5);
    blackColor = color(hue(blackColor), saturation(blackColor), 20);
  }
  
  void onCycleStart() {
    // Start with a full color
    lerpValue = 0;
  }

  void update(long millis) {
    lerpValue += 2 * (millis * 1f / 1000 / kSecondsPerCycle);
    if (lerpValue >= 2) {
      colorMode(HSB, 100);
      currentColor = nextColor;
      nextColor = randomAccentColorWhiter();
      blackColor = lerpColor(currentColor, nextColor, 0.5);
      blackColor = color(hue(blackColor), saturation(blackColor), 20);
      lerpValue = 0;
    }
  }

  color getColor(int strip, int led, Vec3 pos) {
    float effectiveLerp = lerpValue;
    if (effectiveLerp > 1) {
      effectiveLerp = effectiveLerp - 1;
    }
    if (lerpValue <= 1) {
      return lerpColor(currentColor, blackColor, smoothToWave(effectiveLerp));
    } else {
      return lerpColor(blackColor, nextColor, smoothToWave(effectiveLerp));
    }
  }
}
