// Transforms linear 0-1 value to a sinusoidal 0-1 value.
float smooth(float a) {
  return cos(PI*a + PI)/ 2 + 0.5;
}

boolean isRandomChancePerSecondFromMillis(long millis, float chancePerSecond) {
  return random(1) < millis * chancePerSecond / 1000;
}

color randomAccentColor() {
  colorMode(HSB, 100);
  color c =color(random(100), random(70, 100), random(90, 100));
  return c;
}
