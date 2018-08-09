static class ModelDebugLine {
  Vec3[] points;
  color c;

  ModelDebugLine(color c, Vec3[] points) {
    this.points = points;
    this.c = c;
  }
}

static enum ModelLineType {
  BODY(DinoModel.kBodyColor), EYE(DinoModel.kEyeColor), NOSE(DinoModel.kNoseColor), MOUTH(DinoModel.kMouthColor);
  
  public color c;
  
  private ModelLineType(color c) {
    this.c = c;
  }
}

static class ModelLine {
  // There is one point for every LED.
  Vec3[] ledPoints;
  // Minimum number of points needed to draw the line.
  Vec3[] points;

  ModelLineType type;

  ModelLine(Vec3[] linePoints, Vec3[] ledPoints, ModelLineType type) {
    this.points = linePoints;
    this.ledPoints = ledPoints;
    this.type = type;
  }
}

interface Model {
  ModelLine[] getLines();
  ModelDebugLine[] getDebugLines();

  int getMaxLedsOnLines();

  Vec3 getMin();
  Vec3 getMax();

  float getMinX();
  float getMaxX();
  float getMinY();
  float getMaxY();
  float getMinZ();
  float getMaxZ();
}

static Vec3 getModelCenter(Model m) {
  Vec3  center = new Vec3(m.getMinX() + m.getMaxX(), m.getMinY() + m.getMaxY(), m.getMinZ()+ m.getMaxZ());
  center.mulLocal(1f/2);
  return center;
}

static float getModelMaxSize(Model m) {
  Vec3 diff = m.getMax().sub(m.getMin());
  return diff.length();
}


static ModelLine createLedStripLine(Vec3[] linePoints, float offset, int numLeds, float ledSeparationInCM, ModelLineType type) {
  float[] lengths = new float[linePoints.length-1];
  for (int i = 0; i < linePoints.length - 1; i++) {
    lengths[i] = linePoints[i].sub(linePoints[i+1]).length();
  }
  float carryOverLength = offset;
  int pointNum = 0;
  Vec3[] ledPositions = new Vec3[numLeds];
  for (int i = 0; i< lengths.length; ++i) {
    float lengthSoFar = 0;
    Vec3 normal = linePoints[i+1].sub(linePoints[i]);
    normal.mulLocal(1f / normal.length());
    Vec3 current = new Vec3(linePoints[i]);
    current.addLocal(normal.mul(carryOverLength));
    lengthSoFar = carryOverLength;
    normal.mulLocal(ledSeparationInCM);
    do {
      ledPositions[pointNum] = new Vec3(current.x, current.y, current.z);
      pointNum++;
      lengthSoFar += ledSeparationInCM;
      current.addLocal(normal);
    } while ((i == lengths.length - 1 || lengthSoFar < lengths[i]) && pointNum < numLeds);
    if (pointNum >= numLeds)
      break;
    carryOverLength = lengthSoFar - lengths[i];
  }
  return new ModelLine(linePoints, ledPositions, type);
}
