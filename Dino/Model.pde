interface Model {

  int getNumStrips();
  int getNumLedsPerStrip();

  Vec3[] getLedLocations(int stripNum);
  
  Vec3[] getStripLinePoints(int stripNum);

  float getMinX();
  float getMaxX();
  float getMinY();
  float getMaxY();
  float getMinZ();
  float getMaxZ();
}
