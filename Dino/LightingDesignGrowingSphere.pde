class GrowingSpheres implements LightingDesign {
  final float kSphereChancePerSecond = 0.15;
  final float kSphereMinSpeed = 1;
  final float kSphereMaxSpeed = 100;

  class Sphere {
    float radius;
    float speed;
    color c;
  }

  color currentColor;

  Vec3 sphereCenter;
  float sphereRadius;
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
      s.c = randomAccentColor();
    }
    return s;
  }

  void init(Model m) {
    colorMode(HSB, 100);
    sphereCenter = getModelCenter(m);
    maxRadius = getModelMaxSize(m) / 2;

    currentColor = randomAccentColor();
    spheres.add(createSphere());
  }
  void onCycleStart() {
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

  color getColor(int strip, int led, Vec3 pos) {
    float distance = pos.sub(sphereCenter).length();

    for (Sphere s : spheres) {
      if (distance < s.radius)
        return s.c;
    }
    return currentColor;
  }
}
