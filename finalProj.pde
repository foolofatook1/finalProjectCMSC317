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
PVector c1;
PVector c2;
PVector c3;
PVector c4;
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

boolean MOUSE_MODE = false; //true for mouse mode and false for paddle mode

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

  if (MOUSE_MODE == false) {
    cornerPoints = new ArrayList<PVector>();

    float mult = width/height;

    float captureW = 320.0;
    float captureH = captureW/mult;

    cam = new Capture(this, int(captureW), int(captureH));
    cam.start();

    opencv = new OpenCV(this, cam.width, cam.height);

    paddlePos = new PVector();

    c1 = new PVector();
    c2 = new PVector();
    c3 = new PVector();
    c4 = new PVector();

    scaleX = width/captureW;
    scaleY = height/captureH;
  }

  noCursor();

  depth = width;
  panelThickness = width/100;

  initialSpeed = 2*(width/150);
  ballDiameter = width/25;
  ballRadius = ballDiameter/2;

  reset();

  space = loadImage("space.jpg");

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
    if (MOUSE_MODE == true) {
      drawBox(mouseX-(width/12), mouseY, 0, r, g, b, panelThickness, height/6+(panelThickness), panelThickness);
      drawBox(mouseX+(width/12), mouseY, 0, r, g, b, panelThickness, height/6+(panelThickness), panelThickness);
      drawBox(mouseX, mouseY-(height/12), 0, r, g, b, width/6+(panelThickness), panelThickness, panelThickness);
      drawBox(mouseX, mouseY+(height/12), 0, r, g, b, width/6+(panelThickness), panelThickness, panelThickness);
      drawBox(mouseX, mouseY, 0, r, g, b, panelThickness, height/6, panelThickness);
      drawBox(mouseX, mouseY, 0, r, g, b, width/6, panelThickness, panelThickness);
    } else {
      // draws paddle
      drawBox(paddleX-(width/12), paddleY, 0, r, g, b, panelThickness, height/6+(panelThickness), panelThickness);
      drawBox(paddleX+(width/12), paddleY, 0, r, g, b, panelThickness, height/6+(panelThickness), panelThickness);
      drawBox(paddleX, paddleY-(height/12), 0, r, g, b, width/6+(panelThickness), panelThickness, panelThickness);
      drawBox(paddleX, paddleY+(height/12), 0, r, g, b, width/6+(panelThickness), panelThickness, panelThickness);
      drawBox(paddleX, paddleY, 0, r, g, b, panelThickness, height/6, panelThickness);
      drawBox(paddleX, paddleY, 0, r, g, b, width/6, panelThickness, panelThickness);
    }
  } else {
    if (MOUSE_MODE == true) {
      drawBox(mouseX-(width/12), mouseY, 0, r, g, b, panelThickness, height/6+(panelThickness), panelThickness);
      drawBox(mouseX+(width/12), mouseY, 0, r, g, b, panelThickness, height/6+(panelThickness), panelThickness);
      drawBox(mouseX, mouseY-(height/12), 0, r, g, b, width/6+(panelThickness), panelThickness, panelThickness);
      drawBox(mouseX, mouseY+(height/12), 0, r, g, b, width/6+(panelThickness), panelThickness, panelThickness);
      drawBox(mouseX, mouseY, 0, r, g, b, panelThickness, height/6, panelThickness);
      drawBox(mouseX, mouseY, 0, r, g, b, width/6, panelThickness, panelThickness);
      drawBox(mouseX, mouseY, 0, 255, 0, 255, width/6-panelThickness, height/6-panelThickness, panelThickness/2);
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

  if (MOUSE_MODE == false) {
    opencv.loadImage(cam);
    cornerPoints = opencv.findChessboardCorners(3, 3);

    if (cornerPoints.size() >= 5) {
      paddlePos = cornerPoints.get(4);
      paddleX = width-(scaleX*paddlePos.x);
      paddleY = scaleY*paddlePos.y;
    }
  }

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
    if (MOUSE_MODE == true) {
      // CONSTRAINTS IF USING MOUSE
      if (ballPosZ+ballRadius >= 0 && ballPosZ-ballRadius <= 0 && // ball hit paddle
        ballPosX-ballRadius >= mouseX-(width/12) && ballPosX+ballRadius <= mouseX+(width/12) && 
        ballPosY-ballRadius >= mouseY-(width/12) && ballPosY+ballRadius <= mouseY+(width/12)) {
        if (vz < 0) vz*=-1;
        //multiplier+=0.1;
        paddleNow = millis();
        pongSound.play();
      }
    } else {
      // CONSTRAINTS IF USING PADDLE
      if (ballPosZ+ballRadius >= 0 && ballPosZ-ballRadius <= 0 && // ball hit paddle
        ballPosX-ballRadius >= paddleX-(width/12) && ballPosX+ballRadius <= paddleX+(width/12) && 
        ballPosY-ballRadius >= paddleY-(width/12) && ballPosY+ballRadius <= paddleY+(width/12)) {
        if (vz < 0) vz*=-1;
        //multiplier+=0.1;
        paddleNow = millis();
        pongSound.play();
      }
    }
    if (ballPosZ-ballRadius >= (width/4)) reset(); // ball missed paddle
  }

  //println("paddle X: "+paddleX);
  //println("paddle Y: "+paddleY);

  background(0);
  lights();
  pointLight(100, 100, 100, width/2, height/2, -depth);

  pushMatrix();
  translate(0, 0, -2*depth);
  shape(spaceWall);
  popMatrix();

  //prints fps
  pushMatrix();
  textSize(width/50); 
  fill(255, 255, 255); 
  text("FPS: "+int(frameRate), -(width/12), -(height/18), 0); 
  popMatrix();

  //drawPaddle(paddleNow);

  if (cornerPoints.size() >= 9) {

    PVector topLeftCorner = cornerPoints.get(0);
    PVector topCenter = cornerPoints.get(1);
    PVector topRightCorner = cornerPoints.get(2);
    PVector midLeft = cornerPoints.get(3);
    PVector center = cornerPoints.get(4);
    PVector midRight = cornerPoints.get(5);
    PVector botLeftCorner = cornerPoints.get(6);
    PVector botCenter = cornerPoints.get(7);
    PVector botRightCorner = cornerPoints.get(8);

    //sets paddle center
    paddleX = center.x*scaleX;
    paddleY = height-center.y*scaleY;

    c1.x = topLeftCorner.x*scaleX;
    c1.y = height-topLeftCorner.y*scaleY;
    c2.x = topRightCorner.x*scaleX;
    c2.y = height-topRightCorner.y*scaleY;
    c3.x = botLeftCorner.x*scaleX;
    c3.y = height-botLeftCorner.y*scaleY;
    c4.x = botRightCorner.x*scaleX;
    c4.y = height-botRightCorner.y*scaleY;

    //draws paddle
    noFill();
    strokeWeight(6);
    stroke(255, 0, 0);

    //red is correct rotation wrong position
    line(paddleX, paddleY, c1.x, c1.y);
    line(paddleX, paddleY, c2.x, c2.y);
    line(paddleX, paddleY, c3.x, c3.y);
    line(paddleX, paddleY, c4.x, c4.y);
    line(c1.x, c1.y, c2.x, c2.y);
    line(c2.x, c2.y, c4.x, c4.y);
    line(c4.x, c4.y, c3.x, c3.y);
    line(c3.x, c3.y, c1.x, c1.y);

    // blue is correct position wrong rotation
    stroke(0, 0, 255);
    quad(width-topLeftCorner.x*scaleX, topLeftCorner.y*scaleY, width-topRightCorner.x*scaleX, topRightCorner.y*scaleY, 
      width-botRightCorner.x*scaleX, botRightCorner.y*scaleY, width-botLeftCorner.x*scaleX, botLeftCorner.y*scaleY);
    line(width-topCenter.x*scaleX, topCenter.y*scaleY, width-botCenter.x*scaleX, botCenter.y*scaleY);
    line(width-midLeft.x*scaleX, midLeft.y*scaleY, width-midRight.x*scaleX, midRight.y*scaleY);


    /*
    quad(width-topLeftCorner.x*scaleX, topLeftCorner.y*scaleY,
     width-topRightCorner.x*scaleX, topRightCorner.y*scaleY,
     width-botRightCorner.x*scaleX, botRightCorner.y*scaleY, 
     width-botLeftCorner.x*scaleX, botLeftCorner.y*scaleY);
     line(width-topCenter.x*scaleX, topCenter.y*scaleY, width-botCenter.x*scaleX, botCenter.y*scaleY);
     line(width-midLeft.x*scaleX, midLeft.y*scaleY, width-midRight.x*scaleX, midRight.y*scaleY);
     */

    /*
    quad(topLeftCorner.y*scaleY, topLeftCorner.x*scaleX, topRightCorner.y*scaleY, topRightCorner.x*scaleX, 
     botRightCorner.y*scaleY, botRightCorner.x*scaleX, botLeftCorner.y*scaleY, botLeftCorner.x*scaleX);
     line(topCenter.y*scaleY, topCenter.x*scaleX, botCenter.y*scaleY, botCenter.x*scaleX);
     line(midLeft.y*scaleY, midLeft.x*scaleX, midRight.y*scaleY, midRight.x*scaleX);
     */

    /*
     quad(width-botRightCorner.x*scaleX, botRightCorner.y*scaleY, width-botLeftCorner.x*scaleX, botLeftCorner.y*scaleY,
     width-topLeftCorner.x*scaleX, topLeftCorner.y*scaleY, width-topRightCorner.x*scaleX, topRightCorner.y*scaleY);
     line(width-topCenter.x*scaleX, topCenter.y*scaleY, width-botCenter.x*scaleX, botCenter.y*scaleY);
     line(width-midLeft.x*scaleX, midLeft.y*scaleY, width-midRight.x*scaleX, midRight.y*scaleY);
     */
  }

  updateBall();

  if (halt == false) drawBallTrackers();

  drawLines();

  camera(width/2.0, height/2.0, ((height/2.0) / tan(PI*30.0 / 180.0))+(depth/8), width/2.0, height/2.0, 0, 0, 1, 0);
}
