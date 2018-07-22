static class DinoModel implements Model {
  final int kNumStrips = 16;
  final int kStripLengthInCM = 500;
  final int kNumLedsPerStrip = 300;
  final float kLedSeparationInCM = kStripLengthInCM *1f / kNumLedsPerStrip;

  public static final int[] kStripOffsets = {
    // red
    50, 
    // orange  
    0, 
    // yellow
    20, 
    // green  
    0, 
    // light blue  
    100, 
    // dark blue  
    50, 
    // lilac  
    0, 
    // royal purple  
    0, 
    // dash red
    10, 
    // dash orange
    10, 
    // dash yellow
    10, 
    // dash green
    10, 
    // dash light blue
    10, 
    // dash dark blue
    0, 
    // dash light purple
    0, 
    // dash dark purple
    0
  };

  public static final Vec3[][] kStripLines = {
    // red
    {new Vec3(265, 98, 0), new Vec3(234, 195, 145), new Vec3(316, 26, 164), new Vec3(350, 209, 222)}, 
    // orange  
    {new Vec3(185, 187, 0), new Vec3(234.7, 195.5, 143.5), new Vec3(349.7, 208.8, 222.3), new Vec3(500.3, 259.6, 288.7) }, 
    // yellow
    {new Vec3(402.8, 66.8, 252.3), new Vec3(500.4, 10.3, 214.5), new Vec3(500.4, 259.6, 288.7), new Vec3(500.3, 391.8, 368.2)}, 
    // green  
    {new Vec3(402.8, 66.8, 252.3), new Vec3(349.8, 208.9, 222.3), new Vec3(276, 482.1, 81.5)}, 
    // light blue  
    {new Vec3(211.3, 343.67, 0), new Vec3(234.75, 195.5, 143.5), new Vec3(275.9, 482.1, 81.54), new Vec3(211.3, 343.67, 0)}, 
    // dark blue  
    {new Vec3(349.8, 208.9, 222.3), new Vec3(275.95, 482.1, 345.4), new Vec3(500.4, 391.8, 368.2)}, 
    // lilac  
    {new Vec3(402.9, 66.8, 252.3), new Vec3(500.4, 259.6, 288.8), new Vec3(275.95, 482.1, 345.38)}, 
    // royal purple  
    {new Vec3(275.95, 733.04, 426.92), new Vec3(500.4, 594.33, 426.91), new Vec3(500.4, 391.8, 368.25)}, 
    // dash red
    {new Vec3(275.95, 733.04, 426.92), new Vec3(275.95, 482.1, 345.4), new Vec3(500.4, 594.33, 426.91)}, 
    // dash orange
    {new Vec3(275.95, 733.04, 426.92), new Vec3(500.4, 845.3, 496.3), new Vec3(500.4, 594.33, 426.91)}, 
    // dash yellow
    {new Vec3(275.95, 733.04, 426.92), new Vec3(299.64, 995.8, 426.9), new Vec3(500.4, 845.3, 496.3)}, 
    // dash green
    {new Vec3(275.95, 733.04, 426.92), new Vec3(75.2, 883.6, 345.38), new Vec3(299.64, 995.8, 426.9)}, 
    // dash light blue
    {new Vec3(275.95, 733.04, 426.92), new Vec3(137.2, 663.7, 213.46), new Vec3(75.2, 883.6, 345.38)}, 
    // dash dark blue
    {new Vec3(137.2, 663.7, 213.46), new Vec3(75.2, 883.6, 81.5), new Vec3(75.2, 883.6, 345.38)}, 
    // dash light purple
    {new Vec3(17, 727.6, 0), new Vec3(137.2, 663.7, 213.46), new Vec3(120.1, 557.8, 0)}, 
    // dash dark purple
    {new Vec3(137.2, 663.7, 213.46), new Vec3(275.9, 482.1, 81.54), new Vec3(120.1, 557.8, 0)}, 

  };

  public static final ModelDebugLine[] debugLines = new ModelDebugLine[] {
    new ModelDebugLine(#909000, new Vec3[] {new Vec3(212.4, 646.2, 219.3), new Vec3(275.95, 482.1, 81.54), new Vec3(345.73, 357.5, 233.7), new Vec3(275.95, 482.11, 345.38), new Vec3(270.6, 665.6, 337.11), new Vec3(212.4, 646.2, 219.3)}),
    new ModelDebugLine(#909000, new Vec3[] {new Vec3(316.46, 26.68, 164.58), new Vec3(402.85, 66.83, 252.3), new Vec3(334.4, 106.7, 235.56), new Vec3(316.46, 26.68, 164.58)}),
    new ModelDebugLine(#880000, new Vec3[] {new Vec3(265.66, 98, 0), new Vec3(316.5, 26.7, 164.57), new Vec3(500.382, 10.34, 213.49)/*, new Vec3(684.32, 26.6, 164.5), new Vec3(735.1, 98, 0)*/})
  };

  Vec3 min = new Vec3();
  Vec3 max = new Vec3();
  Vec3[][] ledPositions = new Vec3[kStripLines.length][kNumLedsPerStrip];

  DinoModel() {
    assert(kNumStrips == kStripLines.length);
    assert(kNumStrips == kStripOffsets.length);
    calculateLedPositions();
    calculateMinAndMax();
  }

  void calculateLedPositions() {
    // The walks the led strips, and creates a position every kLedSeparationInCM cm.
    for (int stripNum = 0; stripNum < kStripLines.length; stripNum++) {
      Vec3[] points = kStripLines[stripNum];
      float[] lengths = new float[points.length-1];
      for (int i = 0; i < points.length - 1; i++) {
        lengths[i] = points[i].sub(points[i+1]).length();
      }
      float carryOverLength = kStripOffsets[stripNum];
      int pointNum = 0;
      for (int i = 0; i< lengths.length; ++i) {
        float lengthSoFar = 0;
        Vec3 normal = points[i+1].sub(points[i]);
        normal.mulLocal(1f / normal.length());
        Vec3 current = new Vec3(points[i]);
        current.addLocal(normal.mul(carryOverLength));
        lengthSoFar = carryOverLength;
        normal.mulLocal(kLedSeparationInCM);
        do {
          ledPositions[stripNum][pointNum] = new Vec3(current.x, current.y, current.z);
          pointNum++;
          lengthSoFar += kLedSeparationInCM;
          current.addLocal(normal);
        } while ((i == lengths.length - 1 || lengthSoFar < lengths[i]) && pointNum < kNumLedsPerStrip);
        if (pointNum >= kNumLedsPerStrip)
          break;
        carryOverLength = lengthSoFar - lengths[i];
      }
    }
  }

  void calculateMinAndMax() {
    min.set(Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE);
    max.set(-Float.MAX_VALUE, -Float.MAX_VALUE, -Float.MAX_VALUE);
    for (Vec3[] strip : ledPositions) {
      for (Vec3 point : strip) {
        min.x = min(min.x, point.x);
        min.y = min(min.y, point.y);
        min.z = min(min.z, point.z);
        max.x = max(max.x, point.x);
        max.y = max(max.y, point.y);
        max.z = max(max.z, point.z);
      }
    }
  }

  ModelDebugLine[] getDebugLines() {
    return debugLines;
  }

  int getNumStrips() {
    return kNumStrips;
  }
  int getNumLedsPerStrip() {
    return kNumLedsPerStrip;
  }

  Vec3[] getLedLocations(int stripNum) {
    return ledPositions[stripNum];
  }
  Vec3[] getStripLinePoints(int stripNum) {
    return kStripLines[stripNum];
  }

  float getMinX() {
    return min.x;
  }
  float getMaxX() {
    return max.x;
  }
  float getMinY() {
    return min.y;
  }
  float getMaxY() {
    return max.y;
  }
  float getMinZ() {
    return min.z;
  }
  float getMaxZ() {
    return max.z;
  }
}
