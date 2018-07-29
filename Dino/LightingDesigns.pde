enum SinWavesAxis {
  X, Y, Z
};

class SinWaves extends LightingDesign {
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

  List<Wave> waves = new ArrayList<Wave>();

  SinWaves() {
  }

  boolean supportsEyeColors() { 
    return true;
  }
  boolean supportsNoseColors() { 
    return true;
  }
  boolean supportsMouthColors() { 
    return true;
  }

  Wave createWave() {
    Wave w = new Wave();
    w.size = random(kMinWaveSize, kMaxWaveSize);
    w.position = -w.size;
    w.targetColor = randomDifferentAccentColor(ModelLineType.HEAD.c);
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

  color getColor(int stripNum, int ledNum, Vec3 position, ModelLineType type) {
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
    color background = type.c;
    for (Wave w : waves ) {
      float distance = abs(pixelPosition - w.position);
      if (distance < w.size) {
        return lerpColor(w.targetColor, background, smoothToWave(distance / w.size));
      }
    }
    return background;
  }
}

class ColorWave extends LightingDesign {
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

  color getColor(int stripNum, int ledNum, Vec3 position, ModelLineType type) {
    int transformedY = (int)map(position.y, model.getMinY(), model.getMaxY(), 0, waveSegments.length-1);
    return waveSegments[transformedY];
  }
}

class Rain extends LightingDesign {
  final float kRainChancePerSecond = 0.6;

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
    backgroundColorA = #003DA2;
    backgroundColorB = #196EC1;
    color between = lerpColor(backgroundColorA, backgroundColorB, 0.5);
    rainColor = color(hue(between), saturation(between), brightness(between) - 10);
  }

  void onCycleStart() {
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
    if (isRandomChancePerSecondFromMillis(millis, kRainChancePerSecond)) {
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
    if (isRandomChancePerSecondFromMillis(millis, kRainChancePerSecond)) {
      rainsB.add(kRainSpaceMax);
    }
  }

  color getColor(int strip, int led, Vec3 pos, ModelLineType type) {
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

class Pulse extends LightingDesign {
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

  boolean supportsEyeColors() {
    return true;
  }
  boolean supportsNoseColors() {
    return true;
  }
  boolean supportsMouthColors() {
    return true;
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

  color getColor(int strip, int led, Vec3 pos, ModelLineType type) {
    float effectiveLerp = lerpValue;
    if (effectiveLerp > 1) {
      effectiveLerp = effectiveLerp - 1;
    }
    color nextColorOrType = nextColor;
    color currentColorOrType = currentColor;
    if (type != ModelLineType.HEAD) {
      currentColorOrType = type.c;
      nextColorOrType = type.c;
    }
    if (lerpValue <= 1) {
      return lerpColor(currentColorOrType, blackColor, smoothToWave(effectiveLerp));
    } else {
      return lerpColor(blackColor, nextColorOrType, smoothToWave(effectiveLerp));
    }
  }
}

class Physics extends LightingDesign {
  final float kBallMinRadius = 4;
  final float kBalls = 10;
  final float kGravity = 0;
  final float kMaxVelocity = 50;
  final float kBackgroundSecondsPerPulse = 10;

  class Dot {
    float position;
    float velocity;
    float force;
    float mass;
    float radius;
    color c;
  }

  List<Dot> dots = new ArrayList<Dot>();
  float maxRadius;
  Model model;
  color lastColor = #000000;
  color backgroundColorHead = #222222;
  color backgroundColorEye;
  color backgroundColorNose;
  color backgroundColorMouth;
  float backgroundColorPulseMillis = 0;
  float colorAnglePerBall;

  Physics() {
    backgroundColorEye = lerpColor(DinoModel.kEyeColor, #000000, 0);
    backgroundColorNose = lerpColor(DinoModel.kNoseColor, #000000, 0.6);
    backgroundColorMouth = lerpColor(DinoModel.kMouthColor, #000000, 0.6);
  }
  void init(Model m) {
    model = m;
    // Max of half the space should be filled with stripes.
    maxRadius = (m.getMaxZ() - m.getMinZ()) / kBalls / 4;
    colorAnglePerBall = 100f / (kBalls + 1);
  }

  color getNextColor() {
    colorMode(HSB, 100);
    if (lastColor == #000000) {
      lastColor = randomAccentColor();
    } else {
      lastColor = color((hue(lastColor) + colorAnglePerBall) % 100, random(70, 100), random(90, 100));
    }
    return lastColor;
  }

  boolean doesDotIntersectOthers(float position, float radius) {
    for (Dot d : dots) {
      float distance = abs(d.position - position) - (d.radius + radius);
      if (distance < 0)
        return true;
    }
    return false;
  }

  boolean supportsEyeColors() { 
    return true;
  }
  boolean supportsNoseColors() { 
    return true;
  }
  boolean supportsMouthColors() { 
    return true;
  }

  // Called when this design is getting transitioned to
  void onCycleStart() {
    backgroundColorPulseMillis = 0;
    colorMode(HSB, 100);
    dots = new ArrayList<Dot>();
    for (int i = 0; i < kBalls; ++i) {
      Dot dot = new Dot();
      dot.radius = random(kBallMinRadius, maxRadius);
      dot.mass = dot.radius * dot.radius * PI;
      dot.c = getNextColor();
      dot.velocity = random(-kMaxVelocity, kMaxVelocity);
      do {
        dot.position = random(model.getMinZ() + dot.radius, model.getMaxZ() - dot.radius);
      } while (doesDotIntersectOthers(dot.position, dot.radius));
      dots.add(dot);
    }
  }

  void update(long millis) {
    backgroundColorPulseMillis += millis;
    float dt = millis * 1f / 1000;
    for (Dot d : dots) {
      d.velocity += dt * (kGravity  + 1f/d.mass * d.force);
      d.position += dt * d.velocity;
      d.force = 0;
    }

    for (int iteration = 0; iteration < 3; ++iteration) {
      for (int i = 0; i < dots.size(); ++i) {
        Dot a = dots.get(i);

        for (int j = i + 1; j < dots.size(); ++j) {
          Dot b = dots.get(j);
          float distance = abs(b.position - a.position) - (a.radius + b.radius);
          if (distance < 0) {
            // Push them apart
            Dot top = a.position > b.position ? a : b;
            Dot bottom = a.position < b.position ? a : b;
            top.position -= distance / 2;
            bottom.position += distance / 2;

            float totalMass = a.mass + b.mass;
            float va = b.velocity * (2 * b.mass / totalMass) - a.velocity * (b.mass - a.mass) / totalMass;
            float vb = a.velocity * (2 * a.mass / totalMass) - b.velocity * (a.mass - b.mass) / totalMass;
            a.velocity = va;// * 0.95;
            b.velocity = vb;// * 0.95;
          }
        }

        if (a.position - a.radius < 0) {
          a.position = a.radius;
          a.velocity = abs(a.velocity);
        }

        if (a.position + a.radius > model.getMaxZ()) {
          a.position = model.getMaxZ() - a.radius;
          a.velocity = -abs(a.velocity);
        }
      }
    }
  }

  // Called to get color in current state - can be called before update().
  color getColor(int stripNum, int ledNum, Vec3 position, ModelLineType type) {
    for (Dot d : dots) {
      float distance = abs(position.z - d.position);
      if (distance < d.radius) {
        if (type == ModelLineType.HEAD) {
          return d.c;
        } else {
          return lerpColor(d.c, #FFFFFF, 0.4);
        }
      }
    }
    color backgroundColor = type.c;
    if (type == ModelLineType.HEAD) {
      backgroundColor = lerpColor(backgroundColor, #000000, 0.8);
    }
    color backgroundColorBright = lerpColor(backgroundColor, #000000, 0.3);
    color backgroundColorDark = lerpColor(backgroundColor, #000000, 0.7);
    color background = lerpColor(backgroundColorDark, backgroundColorBright, sin(PI*2*backgroundColorPulseMillis / 1000 / kBackgroundSecondsPerPulse) / 2 + 0.5);
    return background;
  }
}

class GrowingSpheres extends LightingDesign {
  final float kSphereChancePerSecond = 0.15;
  final float kSphereMinSpeed = 10;
  final float kSphereMaxSpeed = 80;

  class Sphere {
    float radius;
    float speed;
    color c;
  }

  color currentColor = DinoModel.kBodyColor;

  Vec3 sphereCenter;
  float maxRadius;
  List<Sphere> spheres = new ArrayList<Sphere>();

  GrowingSpheres() {
  }

  Sphere createSphere() {
    Sphere s = new Sphere();
    s.radius = 0;
    s.speed = random(kSphereMinSpeed, kSphereMaxSpeed);
    if (!spheres.isEmpty()) {
      s.c = randomDifferentAccentColor(spheres.get(0).c);
    } else {
      s.c = randomDifferentAccentColor(currentColor);
    }
    return s;
  }

  void init(Model m) {
    colorMode(HSB, 100);
    sphereCenter = getModelCenter(m);
    maxRadius = getModelMaxSize(m) / 2;
    spheres.add(createSphere());
    if (m instanceof DinoModel) {
      sphereCenter.x = 275.95;
    }
  }
  void onCycleStart() {
  }

  boolean supportsEyeColors() { 
    return true;
  }
  boolean supportsNoseColors() { 
    return true;
  }
  boolean supportsMouthColors() { 
    return true;
  }

  void update(long millis) {
    float lastRadius = 0;
    for (int i = 0; i < spheres.size(); ++i) {
      Sphere s = spheres.get(i);
      if (lastRadius > s.radius) {
        spheres.remove(i);
        --i;
      }
      if (lastRadius > maxRadius) {
        spheres.remove(i);
        --i;
        currentColor = s.c;
      }
      s.radius += millis * 1f / 1000 * s.speed;
      lastRadius = s.radius;
    }

    if (isRandomChancePerSecondFromMillis(millis, kSphereChancePerSecond)) {
      spheres.add(0, createSphere());
    }
  }

  color getColor(int strip, int led, Vec3 pos, ModelLineType type) {
    float distance = pos.sub(sphereCenter).length();
    color c = currentColor;
    for (Sphere s : spheres) {
      if (distance < s.radius) {
        c =  s.c;
        break;
      }
    }
    if (type != ModelLineType.HEAD) {
      c = lerpColor(c, type.c, 0.7);
    }
    return c;
  }
}

class Dots extends LightingDesign {
  final int kMillisPerDotMove = 80;
  final float kDotChancePerPixel = 0.2f;

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
    dots = new int[m.getLines().length][m.getLines()[0].ledPoints.length];
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

  boolean supportsEyeColors() { 
    return true;
  }
  boolean supportsNoseColors() { 
    return true;
  }
  boolean supportsMouthColors() { 
    return true;
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

    int[][] newDots = new int[model.getLines().length][model.getLines()[0].ledPoints.length];
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

  color getColor(int stripNum, int ledNum, Vec3 position, ModelLineType type) {
    int dot = dots[stripNum][ledNum];
    if (dot == 0)
      return black;
    if (type != ModelLineType.HEAD) {
      return type.c;
    }
    return dotColor;
  }
}
