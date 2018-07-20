class ColorWave implements LightingDesign {
  float SLOW_COLOR_ADJUST = 0.05;
  float DISCON_CHANCE = 0.0001;
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
  
  void onCycleStart() {}

  color adjustPixel(color input) {
    colorMode(RGB, 255);
    if (random(1) > DISCON_CHANCE) { // 95% of slight adjust
      return color(adjustColor(red(input)), adjustColor(green(input)), adjustColor(blue(input)));
    } else {
      return color(random(255), random(255), random(255));
    }
  }

  int adjustColor(float floatInput) {
    int input = int(floatInput);
    int sign = 1 * random(1) > 0.5 ? -1 : 1;
    int adjust = int(255 * random(SLOW_COLOR_ADJUST));
    return input + (sign * adjust);
  }

  void update(long millis) {
    color adjustedColor = adjustPixel(waveSegments[0]);
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
