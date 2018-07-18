import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;

import processing.core.*;
import java.util.*;

// Press 'n' for next design
// Press 'f' to toggle dino frame
// Press 'a' to toggle auto-cycle

// Draw simple version (no 3d)
final boolean DRAW_SIMPLE = false;
final int SIMPLE_DRAW_SCALE = 5;

// Transition params
final int TIME_BETWEEN_CYCLES_MILLIS = 30*1000;
final float TRANSITION_INC_AMOUNT = 0.05;

Model model = new DinoModel();

// Add more designs here
LightingDesign[] designs = {
  new ColorWave(), 
  new Pulse()
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

void settings() {
  if (DRAW_SIMPLE) {
    size(model.getNumLedsPerStrip() * SIMPLE_DRAW_SCALE, model.getNumStrips() * SIMPLE_DRAW_SCALE);
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
  println("Press N to go to next design");
  println("Press F to toggle wireframe");
  println("Press A to toggle auto-cycle");
  millisLastChange = millis();
}

void nextDesign() {
  if (!transitioning) {
    oldDesign = designs[currentDesign];
  }
  transitioning = true;
  transitionPercent = 0;
  currentDesign++;
  currentDesign = currentDesign % designs.length;
  millisLastChange = millis();
}

void keyTyped() {
  if (key == 'f' || key == 'F')
    drawModelFrame = !drawModelFrame;
  if (key == 'n' || key == 'N')
    nextDesign();
  if (key =='a' || key == 'A')
    autoCycle = !autoCycle;
}

void drawDebug() {
  background(0);
  lights();
  scale(1, 1, -1);
  camera(-500 + (width-mouseX)/2, -300 + (height-mouseY)/2, 500 + (width-mouseX)/2, 700, 700, 0, 0, 0, -1);
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

  sphereDetail(1);
  designs[currentDesign].update();
  for (int strip = 0; strip < model.getNumStrips(); ++strip) {
    Vec3[] stripPoints = model.getLedLocations(strip);
    for (int ledNum = 0; ledNum < stripPoints.length; ++ledNum) {
      Vec3 position = stripPoints[ledNum];
      stroke(getColorForStripLed(strip, ledNum));
      //point(position.x,position.y,position.z);
      translate(position.x, position.y, position.z);
      sphere(1);
      translate(-position.x, -position.y, -position.z);
    }
  }
}

color getColorForStripLed(int strip, int led) {
  Vec3 position = model.getLedLocations(strip)[led];
  color newColor = designs[currentDesign].getColor(strip, led, position);
  if (!transitioning)
    return newColor;

  color oldColor = oldDesign.getColor(strip, led, position);

  if (transitionPercent < 0.5)
    return lerpColor(oldColor, BLACK, smooth(transitionPercent*2));
  return lerpColor(BLACK, newColor, smooth(transitionPercent*2 - 1));
}

void drawSimple() {
  background(0);
  for (int i = 0; i <model.getNumStrips(); i++) {
    for (int j = 0; j< model.getLedLocations(i).length; j++) {
      color c = getColorForStripLed(i, j);
      stroke(c);
      fill(c);
      ellipse(SIMPLE_DRAW_SCALE/2 + j*SIMPLE_DRAW_SCALE, SIMPLE_DRAW_SCALE/2 + i*SIMPLE_DRAW_SCALE, SIMPLE_DRAW_SCALE / 5, SIMPLE_DRAW_SCALE / 5);
    }
  }
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

void draw() {
  if (autoCycle && millisLastChange + TIME_BETWEEN_CYCLES_MILLIS < millis()) {
    nextDesign();
  }

  LightingDesign design = designs[currentDesign];
  if (transitioning) {
    transitionPercent += TRANSITION_INC_AMOUNT;
    if (transitionPercent >= 1) {
      transitioning = false;
    }
  } else {
    design.update();
  }

  if (DRAW_SIMPLE) {
    drawSimple();
  } else {
    drawDebug();
  }
  sendPixelsToPusher();
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
}
