import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;

import processing.core.*;
import java.util.*;

// Press 'n' for next design
// Press 'f' to toggle dino frame
// Press 'a' to toggle auto-cycle

// Draw simple version (no 3d). Use this on old / slow computers.
final boolean kSimpleDraw = false;
final float kSimpleDrawScale = 5;

// Transition params.
final int kCycleTimeMillis = 60*1000;
final float kSecondsForTransition = 5;

Model model = new DinoModel();

// Add more designs here
LightingDesign[] designs = {
  new Dots(), 
  new SinWaves(), 
  new GrowingSpheres(), 
  new ColorWave(), 
  new Pulse(), 
  new Rain()
};

// State variables
int currentDesign = 0;
int millisLastChange = 0;
boolean autoCycle = true;
LightingDesign oldDesign = null;
boolean transitioning = false;
float transitionPercent = 0;
boolean drawModelFrame = false;
final color BLACK = color(0);
DeviceRegistry registry;
StripObserver stripObserver;

long lastTimeUpdate = 0;

void settings() {
  if (kSimpleDraw) {
    size((int)(model.getNumLedsPerStrip() * kSimpleDrawScale), (int)(model.getNumStrips() * kSimpleDrawScale));
  } else {
    size(1024, 1024, P3D);
  }
  registry = new DeviceRegistry();
  stripObserver = new StripObserver();
  registry.addObserver(stripObserver);
  registry.setAntiLog(true);
  registry.setLogging(true);
  registry.setAutoThrottle(true);  
  DeviceRegistry.setOverallBrightnessScale(1);
}

void setup() {
  frameRate(10);
  for (LightingDesign design : designs)
    design.init(model);
  designs[0].onCycleStart();
  println("Press N to go to next design");
  println("Press F to toggle wireframe");
  println("Press A to toggle auto-cycle");
  millisLastChange = millis();
  lastTimeUpdate = millis();
  textSize(20);
}

void draw() {
  if (autoCycle && millisLastChange + kCycleTimeMillis < millis()) {
    nextDesign();
  }
  long newMillis = millis();
  long diff = newMillis - lastTimeUpdate;
  lastTimeUpdate = newMillis;

  LightingDesign design = designs[currentDesign];
  design.update(diff);
  if (transitioning) {
    transitionPercent += diff * 1f / 1000 / kSecondsForTransition;
    if (transitionPercent >= 1) {
      transitioning = false;
    }
    oldDesign.update(diff);
  }

  if (kSimpleDraw) {
    drawSimple();
  } else {
    drawDebug();
  }
  sendPixelsToPusher();
}

void keyTyped() {
  if (key == 'f' || key == 'F')
    drawModelFrame = !drawModelFrame;
  if (key == 'n' || key == 'N')
    nextDesign();
  if (key =='a' || key == 'A')
    autoCycle = !autoCycle;
}


void nextDesign() {
  if (!transitioning) {
    transitionPercent = 0;
    oldDesign = designs[currentDesign];
  }
  transitioning = true;
  currentDesign++;
  currentDesign = currentDesign % designs.length;
  millisLastChange = millis();
  designs[currentDesign].onCycleStart();
}

void drawDebug() {
  background(0);
  lights();
  camera(-500 + (width-mouseX)/2, -300 + (height-mouseY)/2, 500 + (width-mouseX)/2, 500, 700, 0, 0, 0, -1);
  drawGround();

  if (drawModelFrame) {
    for (int i= 0; i<model.getNumStrips(); ++i) {
      Vec3[] points = model.getStripLinePoints(i);
      noFill();
      stroke(255);
      beginShape();
      for (Vec3 p : points) {
        vertex(p.x, p.y, p.z);
      }
      endShape();
    }
  }

  sphereDetail(3);
  for (int strip = 0; strip < model.getNumStrips(); ++strip) {
    Vec3[] stripPoints = model.getLedLocations(strip);
    for (int ledNum = 0; ledNum < stripPoints.length; ++ledNum) {
      Vec3 position = stripPoints[ledNum];
      color c = getColorForStripLed(strip, ledNum);
      stroke(c);
      fill(c);
      translate(position.x, position.y, position.z);
      sphere(0.25f);
      translate(-position.x, -position.y, -position.z);
    }
  }

  for (ModelDebugLine line : model.getDebugLines()) {
    noFill();
    stroke(line.c);
    beginShape();
    for (Vec3 p : line.points) {
      vertex(p.x, p.y, p.z);
    }
    endShape();
  }
}

color getColorForStripLed(int strip, int led) {
  Vec3 position = model.getLedLocations(strip)[led];
  color newColor = designs[currentDesign].getColor(strip, led, position);
  if (!transitioning)
    return newColor;
  color oldColor = oldDesign.getColor(strip, led, position);
  return lerpColor(oldColor, newColor, transitionPercent);
}

void drawSimple() {
  background(0);
  pushMatrix();
  scale(kSimpleDrawScale * 1f / 2);
  for (int i = 0; i <model.getNumStrips(); i++) {
    for (int j = 0; j< model.getLedLocations(i).length; j++) {
      color c = getColorForStripLed(i, j);
      stroke(c);
      fill(c);
      ellipse(j*2 + 1, i*2 + 1, 1, 1);
    }
  }
  popMatrix();
}

void sendPixelsToPusher() {
  if (stripObserver.hasStrips) {
    registry.startPushing();
    registry.setAutoThrottle(true);
    registry.setAntiLog(true);
    List<Strip> strips = registry.getStrips();

    if (strips.size() > 0) {
      for (int i = 0; i < strips.size(); ++i) {
        if (i >= model.getNumStrips())
          break;
        Strip strip = strips.get(i);
        for (int pixel = 0; pixel < strip.getLength(); pixel++) {
          if (pixel >= model.getLedLocations(i).length)
            break;
          strip.setPixel(getColorForStripLed(i, pixel), pixel);
        }
      }
    }
  }
}
void stop() {
  registry.stopPushing();
}

void drawGround() {
  // floor
  colorMode(RGB, 255);
  noStroke();
  fill(10);
  beginShape();
  vertex(0, 0, 0);
  vertex(1400, 0, 0);
  vertex(1400, 1400, 0);
  vertex(0, 1400, 0);
  endShape();
  fill(20);
  beginShape();
  vertex(50, 50, 1);
  vertex(1350, 50, 1);
  vertex(1350, 1350, 1);
  vertex(50, 1350, 1);
  endShape();

  fill(255);
  pushMatrix();
  translate(0, 0, 11);
  rotateZ(PI/2);
  translate(100, -100, 0);
  text("Press 'N' for next design", 0, 0);
  text("Press 'F' to toggle wireframe", 0, 20);
  text("Press A to toggle auto-cycle", 0, 40);
  popMatrix();
}
