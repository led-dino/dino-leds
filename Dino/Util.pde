// Transforms linear 0-1 value to a sinusoidal 0-1 value.
float smoothToWave(float a) {
  return cos(PI*a + PI)/ 2 + 0.5;
}

float smoothArc(float a) {
  return sin(PI*a/2);
}

/** chancePerSecond has to be <= 1 */
boolean isRandomChancePerSecondFromMillis(long millis, float chancePerSecond) {
  // The chance of it NOT happening in a second, is the multiplication of it
  // not happening in all of the 'sub' sections multiplied together.
  int checksPerSecond = (int) (1000f / millis);
  // Calculate the chance it shouldn't happen in this period
  float inverseChance = pow(1-chancePerSecond, 1f / checksPerSecond);
  return random(1) > inverseChance;
}

color randomAccentColor() {
  colorMode(HSB, 100);
  color c =color(random(100), random(60, 100), random(90, 100));
  return c;
}

color randomAccentColorWhiter() {
  colorMode(HSB, 100);
  color c =color(random(100), random(30, 100), random(90, 100));
  return c;
}


color randomDifferentAccentColor(color from) {
  colorMode(HSB, 100);
  color c;
  int hueDistance;
  do {
    c =color(random(100), random(60, 100), random(90, 100));
    hueDistance = (int) min(abs(hue(c)-hue(from)), 100 - abs(hue(c)-hue(from)));
  } while (hueDistance < 20);
  return c;
}
