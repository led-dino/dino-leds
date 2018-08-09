static class DinoModel implements Model {
  final int kNumStrips = 16;
  final int kStripLengthInCM = 500;
  final int kNumLedsPerStrip = 300;
  final float kLedSeparationInCM = kStripLengthInCM *1f / kNumLedsPerStrip;

  public static final color kEyeColor = #FCFF7C;
  public static final color kNoseColor = #FCFF7C;
  public static final color kMouthColor = #FF3639;
  public static final color kBodyColor = #20D32A;

  public static final int[] kHeadStripOffsets = {
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
    20, 
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

  public static final Vec3[][] kHeadStripLines = {
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
    {new Vec3(500.4, 391.8, 368.2), new Vec3(275.95, 482.1, 345.4), new Vec3(349.8, 208.9, 222.3)}, 
    // lilac  
    {new Vec3(402.9, 66.8, 252.3), new Vec3(500.4, 259.6, 288.8), new Vec3(275.95, 482.1, 345.38)}, 
    // royal purple  
    {new Vec3(500.4, 391.8, 368.25), new Vec3(500.4, 594.33, 426.91), new Vec3(275.95, 733.04, 426.92)}, 
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

  public static final int kAccentStripNum = 5;
  
  public static Vec3[][] kEyeStrips = new Vec3[][] {
    {new Vec3(275.95, 482.1, 81.54), new Vec3(212.4, 646.2, 219.3), new Vec3(270.6, 665.6, 337.11), new Vec3(275.95, 482.11, 345.38)},
    {new Vec3(275.95, 482.1, 81.54), new Vec3(345.73, 357.5, 233.7), new Vec3(275.95, 482.11, 345.38), new Vec3(270.6, 665.6, 337.11)}
  };

  public static Vec3[][] kMouthStrips = new Vec3[][] {
    {new Vec3(265.66, 98, 0), new Vec3(316.5, 26.7, 164.57), new Vec3(500.382, 10.34, 213.49), new Vec3(684.32, 26.6, 164.5)}, 
    {new Vec3(735.1, 98, 0), new Vec3(684.32, 26.6, 164.5), new Vec3(500.382, 10.34, 213.49), new Vec3(316.5, 26.7, 164.57)}
  };

  public static Vec3[][] kNoseStrips = new Vec3[][] {
    {new Vec3(316.46, 26.68, 164.58), new Vec3(402.85, 66.83, 252.3), new Vec3(334.4, 106.7, 235.56), new Vec3(316.46, 26.68, 164.58), new Vec3(402.85, 66.83, 252.3), new Vec3(334.4, 106.7, 235.56)}
  };
  
  public static Vec3[][] kRibStrips = new Vec3[][] {
    {new Vec3(402.8, 212, 0), new Vec3(422.8, 262, 235), new Vec3(442.8, 212, 0)},
    {new Vec3(402.8, 577, 0), new Vec3(422.8, 537, 235), new Vec3(442.8, 577, 0)},
    {new Vec3(402.8, 942, 0), new Vec3(422.8, 892, 235), new Vec3(442.8, 942, 0)},
    {new Vec3(555.2, 212, 0), new Vec3(575.2, 262, 235), new Vec3(595.2, 212, 0)},
    {new Vec3(555.2, 577, 0), new Vec3(575.2, 537, 235), new Vec3(595.2, 577, 0)},
    {new Vec3(555.2, 942, 0), new Vec3(575.2, 892, 235), new Vec3(595.2, 942, 0)},
  };

  public static final ModelDebugLine[] debugLines = new ModelDebugLine[] {};

  Vec3 min = new Vec3();
  Vec3 max = new Vec3();

  ModelLine[] lines;

  DinoModel() {
    assert(kNumStrips == kHeadStripLines.length);
    assert(kNumStrips == kHeadStripOffsets.length);
    calculateLedPositions();
    calculateMinAndMax();
  }

  void calculateLedPositions() {
    // The walks the led strips, and creates a position every kLedSeparationInCM cm.
    List<ModelLine> linesList = new ArrayList<ModelLine>();
    for (int i = 0; i < kHeadStripLines.length; i++) {
      Vec3[] points = kHeadStripLines[i];
      linesList.add(createLedStripLine(points, kHeadStripOffsets[i], kNumLedsPerStrip, kLedSeparationInCM, ModelLineType.BODY));
    }
    for (int i = 0; i < kEyeStrips.length; i++) {
      Vec3[] points = kEyeStrips[i];
      linesList.add(createLedStripLine(points, 0, kNumLedsPerStrip, kLedSeparationInCM, ModelLineType.EYE));
    }

    for (int i = 0; i < kMouthStrips.length; i++) {
      Vec3[] points = kMouthStrips[i];
      linesList.add(createLedStripLine(points, 0, kNumLedsPerStrip, kLedSeparationInCM, ModelLineType.MOUTH));
    }

    for (int i = 0; i < kNoseStrips.length; i++) {
      Vec3[] points = kNoseStrips[i];
      linesList.add(createLedStripLine(points, 0, kNumLedsPerStrip, kLedSeparationInCM, ModelLineType.NOSE));
    }
    
    for (int i = 0; i < kRibStrips.length; i++) {
      Vec3[] points = kRibStrips[i];
      linesList.add(createLedStripLine(points, 0, 150, 500f / 150, ModelLineType.BODY));
    }

    lines = linesList.toArray(new ModelLine[0]);
  }

  void calculateMinAndMax() {
    min.set(Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE);
    max.set(-Float.MAX_VALUE, -Float.MAX_VALUE, -Float.MAX_VALUE);
    for (ModelLine strip : lines) {
      for (Vec3 point : strip.ledPoints) {
        min.x = min(min.x, point.x);
        min.y = min(min.y, point.y);
        min.z = min(min.z, point.z);
        max.x = max(max.x, point.x);
        max.y = max(max.y, point.y);
        max.z = max(max.z, point.z);
      }
    }
  }

  ModelLine[] getLines() {
    return lines;
  }

  ModelDebugLine[] getDebugLines() {
    return debugLines;
  }

  int getMaxLedsOnLines() {
    return kNumLedsPerStrip;
  }

  Vec3 getMin() {
    return min;
  }

  Vec3 getMax() {
    return max;
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

class DinoDebugLighting extends LightingDesign {
  final int kMarchSize = 10;
  int march = 0;
  Model m;
  void init(Model m) {
    this.m = m;
  }

  color[] stripColors = new color[] {
    #FF0000, 
    #FFAF00, 
    #FAFF00, 
    #21FF00, 
    #00FFF0, 
    #001BFF, 
    #FE00FF, 
    #BA00FF
  };
  
  
  boolean supportsEyeColors() { 
    return true;
  }
  boolean supportsNoseColors() { 
    return true;
  }
  boolean supportsMouthColors() { 
    return true;
  }

  void update(long millis) {
    march++;
    march %= kMarchSize;
  }

  color getColor(int stripNum, int ledNum, Vec3 position, ModelLineType type) {
    if (ledNum % kMarchSize != march)
      return #000000;
    if (stripNum < DinoModel.kHeadStripLines.length)
      return stripColors[stripNum % 8];
    stripNum -=DinoModel.kHeadStripLines.length;
    if (stripNum < DinoModel.kAccentStripNum)
      return stripColors[stripNum];
    stripNum -=DinoModel.kAccentStripNum;
    return stripColors[stripNum];
  }
}
