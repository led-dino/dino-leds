import java.util.*;

class Rain implements LightingDesign {
  final float kRainChance = 0.05;

  Model model;
  color backgroundColorA;
  color backgroundColorB;
  float backgroundLerpAngle = 0;

  color rainColor;

  final int kRainSpaceMin = 0;
  final int kRainSpaceMax = 300;
  Set<Integer> rainsA = new HashSet<Integer>();
  Set<Integer> rainsB = new HashSet<Integer>();

  Rain() {
  }

  void init(Model m) {
    colorMode(HSB, 100);
    this.model = m;
    backgroundColorA = #195ABF;
    backgroundColorB = #196EC1;
    color between = lerpColor(backgroundColorA, backgroundColorB, 0.5);
    rainColor = color(hue(between), saturation(between), brightness(between) - 10);
  }

  void update(long millis) {
    backgroundLerpAngle += 0.04;
    Set<Integer> newRainsA = new HashSet();
    for (int rain : rainsA) {
      rain--;
      if (rain < 0)
        continue;
      newRainsA.add(rain);
    }
    rainsA = newRainsA;
    if (random(1) < kRainChance) {
      rainsA.add(kRainSpaceMax);
    }

    Set<Integer> newRainsB = new HashSet();
    for (int rain : rainsB) {
      rain--;
      if (rain < 0)
        continue;
      newRainsB.add(rain);
    }
    rainsB = newRainsB;
    if (random(1) < kRainChance) {
      rainsB.add(kRainSpaceMax);
    }
  }

  color getColor(int strip, int led, Vec3 pos) {
    int rainPos = (int) map(pos.z, model.getMinZ(), model.getMaxZ(), kRainSpaceMin, kRainSpaceMax);

    color background = lerpColor(backgroundColorA, backgroundColorB, 0.5f + cos(backgroundLerpAngle)/2);
    if (rainsA.contains(rainPos)) {
      return backgroundColorA;
    }
    if (rainsB.contains(rainPos)) {
      return backgroundColorB;
    }

    // Try to be smoother on the edges
    if (rainsA.contains(rainPos + 1) || rainsA.contains(rainPos - 1)) {
      return lerpColor(background, backgroundColorA, 0.5);
    }
    if (rainsB.contains(rainPos + 1) || rainsB.contains(rainPos - 1)) {
      return lerpColor(background, backgroundColorB, 0.5);
    }

    return background;
  }
}
