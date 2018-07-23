class Dots implements LightingDesign {
  final int kMillisPerDotMove = 100;
  final float kDotChancePerPixel = 0.1f;

  int[][] dots;

  long milliAccum = 0;
  color black;
  color dotColor;

  Dots() {
    black = #000000;
    dotColor = #00F501;
  }

  void init(Model m) {
    model = m;
    dots = new int[m.getNumStrips()][m.getNumLedsPerStrip()];
    initDots();
  }

  void initDots() {
    for (int i = 0; i < dots.length; ++i) {
      for (int j = 0; j < dots[i].length; ++j) {
        if (random(1) > kDotChancePerPixel) {
          dots[i][j] = 0;
        } else {
          // This give us either -1 or 1.
          dots[i][j] = ((int)random(1, 3))*2 - 3;
        }
      }
    }
  }

  void onCycleStart() {
    initDots();
  }

  void setDot(int[] strip, int i, int valAndDirection) {
    while (true) {
      if (i == strip.length || i < 0) {
        valAndDirection*= -1;
        i += valAndDirection;
        continue;
      }
      if (strip[i] == 0) {
        strip[i] = valAndDirection;
        return;
      }
      i += valAndDirection;
    }
  }

  void update(long millis) {
    milliAccum += millis;
    if (milliAccum < kMillisPerDotMove)
      return;
    milliAccum = 0;

    int[][] newDots = new int[model.getNumStrips()][model.getNumLedsPerStrip()];
    for (int i = 0; i < dots.length; ++i) {
      for (int j = 0; j < dots[i].length; ++j) {
        int direction = dots[i][j];
        if (direction == 0)
          continue;
        setDot(newDots[i], j + direction, direction);
      }
    }
    dots = newDots;
  }

  color getColor(int stripNum, int ledNum, Vec3 position) {
    int dot = dots[stripNum][ledNum];
    if (dot == 0)
      return black;
    return dotColor;
  }
}
