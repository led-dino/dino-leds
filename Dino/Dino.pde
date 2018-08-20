import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import org.deepsymmetry.beatlink.*;

import processing.core.*;
import java.util.*;

// Press 'n' for next design
// Press 'f' to toggle dino frame
// Press 'a' to toggle auto-cycle

// No drawing. Use on Raspberry Pi.
final boolean kDrawingEnabled = true;
// Draw simple version (no 3d). Use this on old / slow computers.
final boolean kSimpleDraw = false;
final float kSimpleDrawScale = 5;

// Transition params.
final int kCycleTimeMillis = 3*60*1000;
final float kSecondsForTransition = 5;

Model model = new DinoModel();

// Add more designs here
LightingDesign[] designs = {
  new DinoDebugLighting(), 
  new Physics(), 
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
boolean stopping = false;
boolean fakeBeat = false;

BeatController beatController = new BeatController();

long lastTimeUpdate = 0;

void settings() {
  if (!kDrawingEnabled) {
    size(1, 1);
  } else if (kSimpleDraw) {
    size((int)(model.getMaxLedsOnLines() * kSimpleDrawScale), (int)(model.getLines().length * kSimpleDrawScale));
  } else {
    // to have full screen, uncomment the below line and comment out the 'size' call.
    fullScreen(P3D);
    //size(1024, 1024, P3D);
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
  frameRate(20);
  for (LightingDesign design : designs)
    design.init(model);
  designs[0].onCycleStart();
  println("Press N to go to next design");
  println("Press F to toggle wireframe");
  println("Press A to toggle auto-cycle");
  millisLastChange = millis();
  lastTimeUpdate = millis();
  textSize(20);
  thread("startCdjListening");
}

int fpsCount = 0;
float fpsAvg = 0;
void draw() {
  if (autoCycle && millisLastChange + kCycleTimeMillis < millis()) {
    nextDesign();
  }
  long newMillis = millis();
  long diff = newMillis - lastTimeUpdate;
  fpsAvg = fpsAvg*0.9 + 1f/(diff *1f / 1000)*0.1;
  lastTimeUpdate = newMillis;
  if (++fpsCount >= 20) {
    fpsCount = 0;
    //println(fpsAvg);
  }
  BeatInfo info = beatController.consumeBeat();

  LightingDesign design = designs[currentDesign];
  if (info.beat || fakeBeat) {
    design.onBeat();
  }
  design.update(diff);
  if (transitioning) {
    transitionPercent += diff * 1f / 1000 / kSecondsForTransition;
    if (transitionPercent >= 1) {
      transitioning = false;
    }
    if (info.beat || fakeBeat) {
      oldDesign.onBeat();
    }
    oldDesign.update(diff);
  }
  fakeBeat = false;

  if (kDrawingEnabled) {
    if (kSimpleDraw) {
      drawSimple();
    } else {
      drawDebug();
    }
  }
  sendPixelsToPusher();
}

void keyTyped() {
  if (key == 'f' || key == 'F')
    drawModelFrame = !drawModelFrame;
  if (key == 'n' || key == 'N')
    nextDesign();
  if (key =='c' || key == 'C')
    autoCycle = !autoCycle;
  if (key =='0')
    beatController.armMode(BeatMode.NONE);
  if (key == '1')
    beatController.armMode(BeatMode.EVERY_BEAT);
  if (key == '2')
    beatController.armMode(BeatMode.EVERY_TWO_BEATS);
  if (key == '4')
    beatController.armMode(BeatMode.EVERY_FOUR_BEATS);
  if (key == ' ')
    fakeBeat = true;
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
    for (ModelLine l : model.getLines()) {
      noFill();
      stroke(255);
      beginShape();
      for (Vec3 p : l.points) {
        vertex(p.x, p.y, p.z);
      }
      endShape();
    }
  }

  sphereDetail(3);
  for (int strip = 0; strip < model.getLines().length; ++strip) {
    ModelLine line = model.getLines()[strip];
    for (int ledNum = 0; ledNum < line.ledPoints.length; ++ledNum) {
      Vec3 position = line.ledPoints[ledNum];
      color c = getColorForStripLed(strip, ledNum);
      stroke(c);
      fill(c);
      translate(position.x, position.y, position.z);
      sphere(1);
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
  Vec3 position = model.getLines()[strip].ledPoints[led];
  ModelLineType type = model.getLines()[strip].type;
  LightingDesign current = designs[currentDesign];
  color newColor = getStripColorOrDefaultColor(current, strip, led, position, type);
  if (!transitioning)
    return newColor;
  color oldColor = getStripColorOrDefaultColor(oldDesign, strip, led, position, type);
  return lerpColor(oldColor, newColor, transitionPercent);
}

color getStripColorOrDefaultColor(LightingDesign design, int strip, int ledNum, Vec3 position, ModelLineType type) {
  color newColor = #AAAAAA;
  switch (type) {
  case BODY:
    newColor = design.getColor(strip, ledNum, position, type);
    break;
  case EYE:
    if (design.supportsEyeColors()) {
      newColor = design.getColor(strip, ledNum, position, type);
    } else {
      newColor = DinoModel.kEyeColor;
    }
    break;
  case MOUTH:
    if (design.supportsMouthColors()) {
      newColor = design.getColor(strip, ledNum, position, type);
    } else {
      newColor = DinoModel.kMouthColor;
    }
    break;
  case NOSE:
    if (design.supportsMouthColors()) {
      newColor = design.getColor(strip, ledNum, position, type);
    } else {
      newColor = DinoModel.kNoseColor;
    }
    break;
  }
  return newColor;
}

void drawSimple() {
  background(0);
  pushMatrix();
  scale(kSimpleDrawScale * 1f / 2);
  for (int i = 0; i <model.getLines().length; i++) {
    ModelLine line = model.getLines()[i];
    for (int j = 0; j < line.ledPoints.length; j++) {
      color c = getColorForStripLed(i, j);
      stroke(c);
      fill(c);
      point(j*2 + 1, i*2 + 1);
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
        if (i >= model.getLines().length)
          break;
        Strip strip = strips.get(i);
        for (int pixel = 0; pixel < strip.getLength(); pixel++) {
          if (pixel >= model.getLines()[i].ledPoints.length)
            break;
          strip.setPixel(getColorForStripLed(i, pixel), pixel);
        }
      }
    }
  }
}
void stop() {
  stopping = true;
  registry.stopPushing();
  VirtualCdj.getInstance().stop();
  DeviceFinder.getInstance().stop();
  BeatFinder.getInstance().stop();
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
  fill (20);
  beginShape();
  vertex(50, 50, 1);
  vertex(1350, 50, 1);
  vertex(1350, 1350, 1);
  vertex(50, 1350, 1);
  endShape();

  fill(200);
  pushMatrix();
  translate(0, 0, 11);
  rotateZ(PI/2);
  translate(100, -150, 0);
  int line = 0;
  if (designs[currentDesign] != null) {
    text("Current Design: " + designs[currentDesign].getClass().getSimpleName(), 0, line);
    line+=20;
  }
  text("Press 'N' for next design", 0, line);
  line+=20;
  text("Press 'F' to toggle wireframe " + (drawModelFrame ? "(on)" : "(off)"), 0, line);
  line+=20;
  text("Press C to toggle cycling " + (autoCycle ? "(on)" : "(off)"), 0, line);
  line+=20;
  text("Press 1, 2, or 4 to trigger beat changes every 1, 2, or 4 beats.", 0, line);
  line+=20;
  text("Press 'space' to trigger a fake beat.", 0, line);
  line+=20;
  text("Mode: " + beatController.getMode() + ", bars in mode: " + beatController.getBarsInMode(), 0, line);
  line+=20;

  popMatrix();
}

LifecycleListener cdjListener = new LifecycleListener() {
  void started(LifecycleParticipant sender) {
  }
  void stopped(LifecycleParticipant sender) {
    if (!stopping) {
      DeviceFinder.getInstance().stop();
      BeatFinder.getInstance().stop();
      thread("startCdjListening");
    }
  }
}; 


void startCdjListening() {
  println("starting cdj");

  VirtualCdj.getInstance().addLifecycleListener(cdjListener);
  try {
    VirtualCdj.getInstance().startAndWaitUntilConnected(0);
  } 
  catch (java.net.SocketException e) {
    System.err.println("Unable to start VirtualCdj: " + e);
  }
  println("about to listen");

  VirtualCdj.getInstance().addMasterListener(new MasterListener() {
    public void masterChanged(DeviceUpdate update) {
      System.out.println("Master changed at " + new Date() + ": " + update);
      beatController.onMasterChanged(update);
    }

    public void tempoChanged(double tempo) {
      System.out.println("Tempo changed at " + new Date() + ": " + tempo);
    }

    public void newBeat(Beat beat) {
      //System.out.println("Master player beat at " + new Date() + ": " + beat);
    }
  }
  );
  BeatFinder.getInstance().addBeatListener(new BeatListener() {
    public void newBeat(Beat b) {
      beatController.onBeat(b);
    }
  }
  );
  try {
    BeatFinder.getInstance().start();
  } 
  catch (java.net.SocketException e) {
    System.err.println("Unable to start beatfinder: " + e);
  }

  println("after start");
}
