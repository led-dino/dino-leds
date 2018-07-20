enum ColorWavesAxis {
  X, Y, Z
};

class ColorWaves implements LightingDesign {
  final int kMaxWaveSize = 800;
  final int kMinWaveSize = 5;
  final float kWaveSpeedCMPerSecondMin = 50;
  final float kWaveSpeedCMPerSecondMax = 150;
  final float kWaveChancePerSecond = 0.5;

  class Wave {
    float position;
    float size;
    color targetColor;
  }

  ColorWavesAxis axis;
  Model model;
  float maxPosition;
  float speedCMPerSecond;
  color background = #20D32A;

  List<Wave> waves = new ArrayList<Wave>();

  ColorWaves() {
  }

  Wave createWave() {
    Wave w = new Wave();
    w.size = random(kMinWaveSize, kMaxWaveSize);
    w.position = -w.size;
    w.targetColor = randomColor();
    return w;
  }

  color randomColor() {
    colorMode(HSB, 100);
    color c =color(random(100), random(80, 100), random(80, 100));
    return c;
  }

  void init(Model m) {
    model = m;
    maxPosition = getModelMaxSize(m);
    waves.add(createWave());
  }

  void onCycleStart() {
    axis = ColorWavesAxis.values()[(int)random(ColorWavesAxis.values().length)];
    speedCMPerSecond = random(kWaveSpeedCMPerSecondMin, kWaveSpeedCMPerSecondMax);
  }

  void update(long millis) {
    boolean canCreateNew = true;
    float seconds = millis * 1f / 1000;
    for (int i = 0; i < waves.size(); i++) {
      Wave w = waves.get(i);
      if (w.position - w.size > maxPosition) {
        waves.remove(i);
        --i;
      }
      w.position += seconds * speedCMPerSecond;
      if (w.position - w.size < 0) {
        canCreateNew = false;
      }
    }
    if (canCreateNew && random(1) < seconds * kWaveChancePerSecond) {
      waves.add(createWave());
    }
  }

  color getColor(int stripNum, int ledNum, Vec3 position) {
    float pixelPosition = 0;
    switch(axis) {
      case X:
        pixelPosition = position.x;
        break;
      case Y:
        pixelPosition = position.y;
        break;
      case Z:
        pixelPosition = position.z;
        break;
    }
    for (Wave w : waves ) {
      float distance = abs(pixelPosition - w.position);
      if (distance < w.size) {
        return lerpColor(w.targetColor, background, smooth(distance / w.size));
      }
    }
    return background;
  }
}
