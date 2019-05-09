/**
 * final project
 * Cullen Drissell & Jacob Fisher
 * Scene sketch
 */

import processing.sound.*;
import processing.video.*;
import gab.opencv.*;

PImage img;

Capture cam;
PImage camPic;
PImage calib;
ArrayList<PVector> cornerPoints;
OpenCV opencv;

int depth;
int panelThickness;

float multiplier = 1.0;
float initialSpeed;
float currentVx;
float currentVy;
float currentVz;

float ballDiameter;
float ballRadius;

float ballPosX;
float ballPosY;
float ballPosZ;

float vx;
float vy;
float vz;

boolean halt;
boolean pause = false;
long pauseTime;

long backNow = 0;
long leftNow = 0;
long rightNow = 0;
long topNow = 0;
long bottomNow = 0;
long paddleNow = 0;

PImage space;

PShape spaceWall;

float scaleX;
float scaleY;

float paddleX;
float paddleY;

PVector paddlePos;

SoundFile pongSound;
SoundFile backRsound;
SoundFile backLsound;
SoundFile backCsound;
SoundFile frontRsound;
SoundFile frontLsound;
SoundFile frontCsound;
SoundFile backSound;

void setup() {
  size(800, 600, P3D);
  //fullScreen(P3D);

  cam = new Capture(this, 320, 240);
  cam.start();

  opencv = new OpenCV(this, cam.width, cam.height);

  noCursor();

  scaleX = width/320.0;
  scaleY = height/240.0;

  paddlePos = new PVector();

  depth = width;
  panelThickness = width/100;

  initialSpeed = 2*(width/150);
  ballDiameter = width/25;
  ballRadius = ballDiameter/2;

  reset();

  space = loadImage("space.jpg");
  //space.resize(width, height);

  noStroke();
  noFill();
  spaceWall = createShape(RECT, -2*width, -2*height, 5*width, 5*height);
  spaceWall.setTexture(space);

  pongSound = new SoundFile(this, "pingpong.mp3");
  backRsound = new SoundFile(this, "bounceBackRight.mp3");
  backLsound = new SoundFile(this, "bounceBackLeft.mp3");
  backCsound = new SoundFile(this, "bounceBackTopBot.mp3");
  frontRsound = new SoundFile(this, "bounceFrontRight.mp3");
  frontLsound = new SoundFile(this, "bounceFrontLeft.mp3");
  frontCsound = new SoundFile(this, "bounceFrontTopBot.mp3");
  backSound = new SoundFile(this, "bounceBack.mp3");
}

void reset() {
  ballPosX = width/2;
  ballPosY = height/2;
  ballPosZ = -ballDiameter;

  vx = 0.0;
  vy = 0.0;
  vz = 0.0;

  halt = true;
}


// method to draw box objects in the game
void drawBox(float translateX, float translateY, float translateZ, int r, int g, int b, int w, int h, int d) {
  pushMatrix();
  translate(translateX, translateY, translateZ);
  noStroke();
  fill(r, g, b);
  box(w, h, d);
  popMatrix();
}

// method to draw the ball trackers that appear on the walls, floor, and ceiling
void drawBallTrackers() {
  int r = 0;
  int g = 0;
  int b = 0;
  // LEFT WALL TRACKER
  drawBox(-(panelThickness/2), height/2, ballPosZ, r, g, b, panelThickness+5, height, panelThickness+5);

  // RIGHT WALL TRACKER
  drawBox(width+(panelThickness/2), height/2, ballPosZ, r, g, b, panelThickness+5, height, panelThickness+5);

  // TOP WALL TRACKER
  drawBox(width/2, -(panelThickness/2), ballPosZ, r, g, b, width, panelThickness+5, panelThickness+5);

  // BOTTOM WALL TRACKER
  drawBox(width/2, height+(panelThickness/2), ballPosZ, r, g, b, width, panelThickness+5, panelThickness+5);
}


// method to update the balls position and draw the ball
void updateBall() {
  // updates ball position
  ballPosX += multiplier*vx;
  ballPosY += multiplier*vy;
  ballPosZ -= multiplier*vz;

  // DRAWS BALL
  pushMatrix();
  translate(ballPosX, ballPosY, ballPosZ);
  noStroke();
  fill(0, 255, 0);
  sphere(ballDiameter);
  popMatrix();
}

// method to draw the paddle
void drawPaddle(long time) {
  long current = millis();
  int r = 255;
  int g = 255;
  int b = 255;
  if (current - time > 150) {
    // draws paddle
    drawBox(paddleX-(width/12), paddleY, 0, r, g, b, panelThickness, height/6+(panelThickness), panelThickness);
    drawBox(paddleX+(width/12), paddleY, 0, r, g, b, panelThickness, height/6+(panelThickness), panelThickness);
    drawBox(paddleX, paddleY-(height/12), 0, r, g, b, width/6+(panelThickness), panelThickness, panelThickness);
    drawBox(paddleX, paddleY+(height/12), 0, r, g, b, width/6+(panelThickness), panelThickness, panelThickness);
    drawBox(paddleX, paddleY, 0, r, g, b, panelThickness, height/6, panelThickness);
    drawBox(paddleX, paddleY, 0, r, g, b, width/6, panelThickness, panelThickness);
  } else {
    // draws paddle when hit
    drawBox(paddleX-(width/12), paddleY, 0, r, g, b, panelThickness, height/6+(panelThickness), panelThickness);
    drawBox(paddleX+(width/12), paddleY, 0, r, g, b, panelThickness, height/6+(panelThickness), panelThickness);
    drawBox(paddleX, paddleY-(height/12), 0, r, g, b, width/6+(panelThickness), panelThickness, panelThickness);
    drawBox(paddleX, paddleY+(height/12), 0, r, g, b, width/6+(panelThickness), panelThickness, panelThickness);
    drawBox(paddleX, paddleY, 0, r, g, b, panelThickness, height/6, panelThickness);
    drawBox(paddleX, paddleY, 0, r, g, b, width/6, panelThickness, panelThickness);
    drawBox(paddleX, paddleY, 0, 255, 0, 255, width/6-panelThickness, height/6-panelThickness, panelThickness/2);
  }
}

// method to draw the cage lines
void drawLines() {
  int r = 140;
  int g = 100;
  int b = 150;
  for (int i = 0; i <= (2*depth); i+=(2*depth)/20) {
    // draws rings down the chamber
    drawBox(0, height/2, -i, r, g, b, panelThickness, height+panelThickness, panelThickness);
    drawBox(width, height/2, -i, r, g, b, panelThickness, height+panelThickness, panelThickness);
    drawBox(width/2, 0, -i, r, g, b, width+panelThickness, panelThickness, panelThickness);
    drawBox(width/2, height, -i, r, g, b, width+panelThickness, panelThickness, panelThickness);
  }
  for (int j = 0; j <= width; j += width/((width/height)*6)) {
    // draws ceiling lines
    drawBox(j, height, -depth, r, g, b, panelThickness, panelThickness, 2*depth);
    drawBox(j, 0, -depth, r, g, b, panelThickness, panelThickness, 2*depth);
    drawBox(j, height/2, -2*depth, r, g, b, panelThickness, height, panelThickness);
  }
  // draws wall lines
  for (int k = 0; k <= height; k += height/((width/height)*6)) {
    drawBox(0, k, -depth, r, g, b, panelThickness, panelThickness, 2*depth); 
    drawBox(width, k, -depth, r, g, b, panelThickness, panelThickness, 2*depth);
    drawBox(width/2, k, -2*depth, r, g, b, width, panelThickness, panelThickness);
  }
}


void draw() {

  //println(frameRate);

  //camPic = cam.get();
  opencv.loadImage(cam);
  //if (frameCount%2 == 1) 
  cornerPoints = opencv.findChessboardCorners(3, 3);

  /*
  for (PVector p : cornerPoints) {
   System.out.println(p);
   }
   System.out.println();
   */

  if (keyPressed) {
    if (key == 'r' || key == 'R') reset();
    if ((key == 'p' || key == 'P') && pause == false) {
      currentVx = vx;
      currentVy = vy;
      currentVz = vz;
      vx = 0;
      vy = 0;
      vz = 0;
      pause = true;
    } else if ((key == 'p' || key == 'P') && pause == true) {
      vx = currentVx;
      vy = currentVy;
      vz = currentVz;
      pause = false;
    }
  }

  if (halt == true && mousePressed) {
    halt = false;

    ballPosX = width/2;
    ballPosY = height/2;
    ballPosZ = -ballRadius-1;

    if (Math.random()<0.5) {
      vx = initialSpeed;
    } else vx = -initialSpeed;
    if (Math.random()<0.5) {
      vy = initialSpeed;
    } else vy = -initialSpeed;
    vz = initialSpeed;
  } else if (halt == false) {
    if (ballPosZ-ballRadius <= -2*depth) { // ball hit back wall
      vz*=-1;
      backNow = millis();
      backSound.play();
    } 
    if ( ballPosX-ballRadius <= 0) { // ball hit left wall
      vx*=-1;
      leftNow = millis();
      if (ballPosZ < -depth) backLsound.play();
      else frontLsound.play();
    } 
    if (ballPosX+ballRadius >= width ) { // ball hit right wall
      vx*=-1;
      rightNow = millis();
      if (ballPosZ < -depth) backRsound.play();
      else frontRsound.play();
    } 
    if (ballPosY+ballRadius >= height) { // ball hit top wall
      vy*=-1;
      topNow = millis();
      if (ballPosZ < -depth) backCsound.play();
      else frontCsound.play();
    } 
    if (ballPosY-ballRadius <= 0) { // ball hit bottom wall
      vy*=-1;
      bottomNow = millis();
      if (ballPosZ < -depth) backCsound.play();
      else frontCsound.play();
    } 
    if (ballPosZ+ballRadius >= 0 && ballPosZ-ballRadius <= 0 && // ball hit paddle
      ballPosX-ballRadius >= mouseX-(width/12) && ballPosX+ballRadius <= mouseX+(width/12) && 
      ballPosY-ballRadius >= mouseY-(width/12) && ballPosY+ballRadius <= mouseY+(width/12)) {
      if (vz < 0) vz*=-1;
      //multiplier+=0.1;
      paddleNow = millis();
      pongSound.play();
    } 
    if (ballPosZ-ballRadius >= (width/4)) reset(); // ball missed paddle
  }

  background(0);
  lights();
  pointLight(100, 100, 100, width/2, height/2, -depth);

  pushMatrix();
  translate(0, 0, -2*depth);
  shape(spaceWall);
  popMatrix();

  updateBall();

  if (cornerPoints.size() >= 5) {
    paddlePos = cornerPoints.get(5);
    paddleX = scaleX*paddlePos.x;
    paddleY = scaleY*paddlePos.y;
  }

  drawPaddle(paddleNow);

  if (halt == false) drawBallTrackers();

  drawLines();

  camera(width/2.0, height/2.0, ((height/2.0) / tan(PI*30.0 / 180.0))+(depth/8), width/2.0, height/2.0, 0, 0, 1, 0);
}
