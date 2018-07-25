class ColorWave implements LightingDesign {
  final float kAdjustPercentPerSecond = 0.8;
  final float kDisconnectedColorChancePerSecond = 0.05f;
  int NUM_SEGMENTS = 300;

  color[] waveSegments = new color[NUM_SEGMENTS];
  Model model;

  ColorWave() {
  }

  void init(Model m) {
    model = m;
    colorMode(RGB, 255);
    color c = color(random(255), random(255), random(255));
    for (int i = 0; i < waveSegments.length; ++i) {
      waveSegments[i] = c;
    }
  }

  void onCycleStart() {
  }

  color adjustPixel(color input, long millis) {
    colorMode(RGB, 255);
    if (isRandomChancePerSecondFromMillis(millis, kDisconnectedColorChancePerSecond)) {
      return color(random(255), random(255), random(255));
    }
    return color(adjustColor(red(input), millis), adjustColor(green(input), millis), adjustColor(blue(input), millis));
  }

  int adjustColor(float floatInput, long millis) {
    int input = int(floatInput);
    int sign = 1 * random(1) > 0.5 ? -1 : 1;
    int adjust = int(255 * random(kAdjustPercentPerSecond * millis / 1000));
    return input + (sign * adjust);
  }

  void update(long millis) {
    color adjustedColor = adjustPixel(waveSegments[0], millis);
    for (int i = waveSegments.length - 1; i >= 0; --i) {
      if (i == 0)
        waveSegments[i] = adjustedColor;
      else
        waveSegments[i] = waveSegments[i-1];
    }
  }

  color getColor(int stripNum, int ledNum, Vec3 position) {
    int transformedY = (int)map(position.y, model.getMinY(), model.getMaxY(), 0, waveSegments.length-1);
    return waveSegments[transformedY];
  }
}
