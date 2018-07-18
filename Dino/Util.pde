// Transforms linear 0-1 value to a sinusoidal 0-1 value.
float smooth(float a) {
  return cos(PI*a + PI)/ 2 + 0.5; 
}
