enum SinWavesAxis {
  X, Y, Z
};

class SinWaves implements LightingDesign {
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

  SinWavesAxis axis;
  Model model;
  float maxPosition;
  float speedCMPerSecond;
  color background = #20D32A;

  List<Wave> waves = new ArrayList<Wave>();

  SinWaves() {
  }

  Wave createWave() {
    Wave w = new Wave();
    w.size = random(kMinWaveSize, kMaxWaveSize);
    w.position = -w.size;
    w.targetColor = randomAccentColor();
    return w;
  }

  void init(Model m) {
    model = m;
    maxPosition = getModelMaxSize(m);
    waves.add(createWave());
  }

  void onCycleStart() {
    axis = SinWavesAxis.values()[(int)random(SinWavesAxis.values().length)];
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
    if (canCreateNew && isRandomChancePerSecondFromMillis(millis, kWaveChancePerSecond)) {
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
