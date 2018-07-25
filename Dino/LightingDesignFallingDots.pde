class FallingDots implements LightingDesign {
  final float kBallMinRadius = 4;
  final float kBalls = 10;
  final float kGravity = 0;
  final float kMaxVelocity = 50;

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
  float colorAnglePerBall;
  
  FallingDots() {
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
      lastColor =color((hue(lastColor) + colorAnglePerBall) % 100 , random(70, 100), random(90, 100));
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

  // Called when this design is getting transitioned to
  void onCycleStart() {
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
      println(dot.position);
      dots.add(dot);
    }
  }

  void update(long millis) {
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
  color getColor(int stripNum, int ledNum, Vec3 position) {
    for (Dot d : dots) {
      float distance = abs(position.z - d.position);
      if (distance < d.radius) {
        return d.c;
      }
    }
    return #000000;
  }
}
