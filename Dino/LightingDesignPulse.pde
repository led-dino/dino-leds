class Pulse implements LightingDesign {
  final float LERP_INCREMENT = 0.02;

  color currentColor;
  color nextColor;
  color blackColor;
  // from 0 to 2, taking into account black in between.
  float lerpValue = 0;

  Pulse() {
  }

  color randomColor() {
    colorMode(HSB, 100);
    color c =color(random(100), random(80, 100), 100);
    return c;
  }

  void init(Model m) {
    colorMode(HSB, 100);
    currentColor = randomColor();
    nextColor = randomColor();
    blackColor = lerpColor(currentColor, nextColor, 0.5);
    blackColor = color(hue(blackColor), saturation(blackColor), 20);
  }
  
  void onCycleStart() {
    // Start with a full color
    lerpValue = 0;
  }

  void update(long millis) {
    lerpValue += LERP_INCREMENT;
    if (lerpValue >= 2) {
      colorMode(HSB, 100);
      currentColor = nextColor;
      nextColor = randomColor();
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
      return lerpColor(currentColor, blackColor, smooth(effectiveLerp));
    } else {
      return lerpColor(blackColor, nextColor, smooth(effectiveLerp));
    }
  }
}
