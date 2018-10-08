// import necessary libraries and initialize objects
import controlP5.*;
import peasy.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

ControlP5 cp5;
PeasyCam cam;
Minim minim;
FFT listen;
AudioInput in;

// accessories for gui elements
float rate;
float wobbles;
boolean type = false;

// array for spherical geometry; resolution of sphere
PVector[][] globe;
int polygons = 100;

// color change variables
float R = 125;
float centerR = 125;
float w = PI/2;
float w1 = PI;
float w2 = 3 * PI/2;
float pathR = 125;
float pathG = 125;
float G = 125;
float centerG = 125;
float pathB = 125;
float B = 125;
float centerB = 125;

void setup() {
  size(displayWidth, displayHeight, P3D);
  smooth();
  
  cp5 = new ControlP5(this);
  cam = new PeasyCam(this, 500);
  globe = new PVector[polygons+1][polygons+1];
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 2048, 192000.0);
  listen = new FFT(in.bufferSize(), in.sampleRate());
  
  cp5.addSlider("chill")
     .setPosition(50, 50)
     .setSize(300, 10)
     .setRange(0, 0.1)
     .setValue(0.01);
     
  cp5.addSlider("hype")
     .setPosition(50, 100)
     .setSize(300, 10)
     .setRange(0, 5)
     .setValue(1.1);
  
  cp5.addToggle("wavy/freaky")
     .setPosition(40,250)
     .setSize(50,20)
     .setValue(true)
     .setMode(ControlP5.SWITCH)
     ;
  
  cp5.setAutoDraw(false);
  cp5.getController("chill").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("chill").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("hype").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("hype").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

}

void draw() {
  background(0);
  noStroke();
  fill(pathR, pathG, pathB);
  lights();
  
  pushMatrix();
  if(type==true) {
    waveSphere(200);
  } else {
    freakSphere(200);
  }
  popMatrix();
  
  listen.forward(in.mix);
  
  pathR = centerR + R * sin(w);
  w = w + rate;
  pathG = centerG + G * sin(w1);
  w1 = w1 + rate;
  pathB = centerB + B * sin(w2);
  w2 = w2 + rate;
  
  gui();  
}

// draws a wavy sphere with radius r
void waveSphere(float r) {
  for (int i = 0; i < polygons+1; i++) {
    float lat = map(i, 0, polygons, -HALF_PI, HALF_PI);
    float r2 = 1 + in.left.get(i) * wobbles;
    for (int j = 0; j < polygons+1; j++) {
      float lon = map(j, 0, polygons, -PI, PI);
      float r1 = 1 + in.left.get(j) * wobbles;
      float x = r * r1 * cos(lon) * r2 * cos(lat);
      float y = r * r1 * sin(lon) * r2 * cos(lat);
      float z = r * r2 * sin(lat);
      globe[i][j] = new PVector(x, y, z);
    }
  }
  for (int i = 0; i < polygons; i++) {
    beginShape(TRIANGLE_STRIP);
    for (int j = 0; j < polygons+1; j++) {
      PVector v1 = globe[i][j];
      vertex(v1.x, v1.y, v1.z);
      PVector v2 = globe[i+1][j];
      vertex(v2.x, v2.y, v2.z);
    }
    endShape();
  }
}

// draws a freaky sphere with radius r
void freakSphere(float r) {
  float scale = 0.1 * (log(wobbles));
  for (int i = 0; i < polygons+1; i++) {
    float lat = map(i, 0, polygons, -HALF_PI, HALF_PI);
    float r2 = 1 + listen.getBand(i) * scale;
    for (int j = 0; j < polygons+1; j++) {
      float lon = map(j, 0, polygons, -PI, PI);
      float r1 = 1 + listen.getBand(j) * scale;
      float x = r * r1 * cos(lon) * r2 * cos(lat);
      float y = r * r1 * sin(lon) * r2 * cos(lat);
      float z = r * r2 * sin(lat);
      globe[i][j] = new PVector(x, y, z);
    }
  }
  for (int i = 0; i < polygons; i++) {
    beginShape(TRIANGLE_STRIP);
    for (int j = 0; j < polygons+1; j++) {
      PVector v1 = globe[i][j];
      vertex(v1.x, v1.y, v1.z);
      PVector v2 = globe[i+1][j];
      vertex(v2.x, v2.y, v2.z);
    }
    endShape();
  }
}

// main gui initializer
void gui() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

// gui element initializers
void chill(float deltaR) {
  rate = deltaR;
  println("chill set to: " + rate);
}

void hype(float wobs) {
  wobbles = wobs;
  println("hype set to: " + wobbles);
}

void wavyorfreaky(boolean theFlag) {
  if(theFlag==true) {
    type = true;
    println("set input to wavy");
  } else {
    type = false;
    println("set input to freaky:");
  }
  
}
