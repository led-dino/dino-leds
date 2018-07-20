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

Vec3 getModelCenter(Model m) {
  Vec3  center = new Vec3(m.getMinX() + m.getMaxX(), m.getMinY() + m.getMaxY(), m.getMinZ()+ m.getMaxZ());
  center.mulLocal(1f/2);
  return center;
}

float getModelMaxSize(Model m) {
  return max(max(m.getMaxX() - m.getMinX(), m.getMaxY() - m.getMinY()), m.getMaxZ() - m.getMinZ());
}
