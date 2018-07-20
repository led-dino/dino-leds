interface LightingDesign {
  // Called once, first, with the model to be designed.
  void init(Model m);
  // Called to update movement etc, repeatedly per frame
  void update(long millis);
  // Called to get color in current state - can be called before update().
  color getColor(int stripNum, int ledNum, Vec3 position);   
}
