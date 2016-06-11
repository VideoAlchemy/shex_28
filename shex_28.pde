/*******************************************************************
 * shex_28
 * an interactive installation for Suzan's 28hexadecimal birthday (ie 40)
 * Copyright (c) 2016 Jason Stephens & Video Alchemy Collective
 * The MIT License (MIT)
 *******************************************************************/
/*NOTES:
 - mask sillouettes by either threshold detection in the pixel array OR with BLEND in applyMaskToBuffer function
 */
import processing.video.*;
import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;


Kinect kinect;

PImage   gDepthImage;
PImage   gSilBuffer;
PGraphics gDepthBoxBuffer;
int      numOfPreviousDepthImages = 10;
PImage[] gPreviousDepthImages     = new PImage[numOfPreviousDepthImages];
int []   gRawDepth;
int      gPixelSkip               = 1; //cell size when iterating the array



String  SNAP_FOLDER_PATH       = "../ops-board-snaps/";
PImage refImage;
PImage bufferImage;
PImage videoBufferImage;
PImage prevFrame;
PGraphics buffer;
PGraphics msk;
Movie video;
float outputScale = 1.6;

////////////////SET VID TRANSFORMS
float theta          = 0;
float maxRot         = 0.003;//.003
float noiseOffset    = random(1000);
float noiseIncrement = .002;//.001
float vidSpeed       = .5;

float amountToScale  = 0;
float minScale       = 1.4;
float maxScale       = 3;
float noiseScale     = random(40);
float noiseScaleIncrement = .001; //.001

/////////////////////END VIDEO TRANSFORM

void setup() {
  size(1024, 768, P3D);
  //fullScreen(P3D,3);
  noStroke();
  smooth();

  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.enableMirror(mirror);

  //initialize our PImages
  gSilBuffer = createImage(kinect.width, kinect.height, ARGB);
  
  gDepthBoxBuffer = createGraphics(kinect.width, kinect.height);

  //////////////VIDEO
  video = new Movie(this, "rotaVid.mov");
  video.loop();
  /////jump to random location
  //println(video.duration());
  video.jump(random(3000));
  video.speed(vidSpeed);//.5,5
  videoBufferImage = createImage(kinect.width, kinect.height, ARGB);
  ///////////////////

  refImage     = loadImage("shex-452.jpg");
  prevFrame    = createImage(width, height, ARGB);
  bufferImage  = createImage(refImage.width, refImage.height, ARGB);
  buffer       = createGraphics(refImage.width, refImage.height);
  msk          = createGraphics(refImage.width, refImage.height);

  buffer.beginDraw();
  buffer.noStroke();
  buffer.endDraw();

  background(0);
}

void draw() {
  updateMaskGraphic();


  //GET RAW DEPTH as an array of intergers (0-2048mm)
  gRawDepth = kinect.getRawDepth();

  //or just get the DEPTH IMAGE
  gDepthImage = kinect.getDepthImage();
  //image(gDepthImage, 0, 0);


  /////LOAD THE PIXEL ARRAYS
  loadPixels();
  gDepthImage.loadPixels();
  gSilBuffer.loadPixels();

  msk.loadPixels();
  refImage.loadPixels();
  bufferImage.loadPixels();
  

  /////////////////////INDEX INTO THE DEPTH ARRAY///////////////////////////
  // EXTRACT A THRESHOLD SILOUETTE AND DRAW IT TO gSilBuffer 
  for (int x = 0; x < kinect.width; x+=gPixelSkip) {
    for (int y = 0; y < kinect.height; y+=gPixelSkip) {
      int index = x + y * kinect.width;
      int depth = gRawDepth[index];  

      ///// TEST AGAINST THRESHOLD
      // if the distance from camera is further than the max threshold, then set that pixel to black
      if ((depth > MAX_THRESH) || (depth < MIN_THRESH)) {
        gSilBuffer.pixels[index] = color(0, 0);
      } else {
        ////////EXTRACT BRIGHTNESS
        float b = map(depth, 200, MAX_THRESH, 255, 10);  //float b = brightness(depth);//brightness(depth);//
        b*=3; //scalar to pump up the brightness
        
        //////////////////////////////////////////////////HERE
        gSilBuffer.pixels[index] = color(b);
        //rect(x*outputScale, y*outputScale, gPixelSkip, gPixelSkip);
        //////////////////////////////////////////////////HERE
        
        //   1. extract the raw depth and inform fill and 3D
        //   2. extract a greyscale image and draw it to the gSilBuffer

        // EXTRACT RAW DEPTH and DRAW 3D SQUARES
        /*
        //float z = map(depth, MIN_THRESH, MAX_THRESH, 400*3, -200); //units along the z axis ////
        float z = map(b, 0, 255, 250, -250); //units along the z axis
         fill(b);
         pushMatrix();
         translate(x*gPixelSkip, y*gPixelSkip, z);
         box(gPixelSkip);
         //rect(0, 0, gPixelSkip, gPixelSkip);
         popMatrix();
         */
      }
    }
  }
  /////////////////////ENDINDEX INTO THE DEPTH ARRAY///////////////////////////

  ////////////////////////////////////////////////////////////////////////////////////////////////
  updatePixels();
  gSilBuffer.updatePixels();
  gDepthImage.updatePixels();
  image(gSilBuffer, 0, 0, width, height);
  ////////////////////////////////////////////////////////////////////////////////////////////////



  /////LOAD THE PIXEL ARRAYS
  loadPixels();
  gDepthImage.loadPixels();
  gSilBuffer.loadPixels();
  msk.loadPixels();
  refImage.loadPixels();
  bufferImage.loadPixels();
  videoBufferImage.loadPixels();


  //COPY THE VIDEO FRAME INTO THE VIDEO BUFFER IMAGE, THEN RESIZE the BUFFERIMAGE
  /*Copies a region of pixels from one image into another. 
  If the source and destination regions aren't the same size, 
  it will automatically resize source pixels to fit the specified target region. 
  No alpha information is used in the process, however if the source image has an alpha channel set, it will be copied as well. 
  */
  
  videoBufferImage.copy(video,0,0,video.width,video.height,0,0,videoBufferImage.width, videoBufferImage.height);
  
  
  
  
  //INDEX INTO THE REFERENCE IMAGES
  for (int x = 0; x < refImage.width; x++) {
    for (int y = 0; y < refImage.height; y++) {
      int index = x + y*refImage.width;
      ////////////////////////////////

      // TEST SILOUETTES THRESHOLD
      //DRAW pixel color from VIDEO frame TO bufferImage when pixel brightness at that index on gSilBuffer > threshold
      float silPixelBrightness = brightness(gSilBuffer.pixels[index]);
      if (silPixelBrightness > 5) {
        bufferImage.pixels[index] = videoBufferImage.pixels[index];//color(255);
      } else {
        bufferImage.pixels[index] = color(0);
      }

        //float b = brightness(depth);//brightness(depth);//
        
        
        // EXTRACT RAW DEPTH and DRAW 3D SQUARES
        /*
         silPixelBrightness*=3;
         float z = map(silPixelBrightness, 0, 255, 250, -250); //units along the z axis
         fill(silPixelBrightness);
         pushMatrix();
         translate(x, y, z);
         //box(gPixelSkip*10);
         rect(0, 0, gPixelSkip, gPixelSkip);
         popMatrix();
         */


      /*
      //USE BRIGHTNESS on msk to set equivelant pixel on bufferImage to the color of the refeImage
      //otherwise, make it black
      float pixelBrightnessInMaskImage = brightness(msk.pixels[index]);
      if (pixelBrightnessInMaskImage > 20) {
        bufferImage.pixels[index] = refImage.pixels[index];
      } else {
        bufferImage.pixels[index] = color(0);
      }
      */////////////////////////////////
      
      /*
      float r = red(refImage.pixels[index]);
      float g = green(refImage.pixels[index]);
      float b = blue(refImage.pixels[index]);
      //float d = dist(x,y, refImage.width/2, refImage.height/2);
      //float d = dist(x*outputScale,y*outputScale, mouseX, mouseY);
      //float factor = map(d, 0, 200, 1, -1);
       */
      ///////////////
      //SET bufferImage to refImage
      /////this seems inefficient.  It sets ALL the pixels, then masks out most
      //bufferImage.pixels[index] = color(b,g,r);
    }
  }
  //paintWithRandomCirclesFrom();

  ///////////////////////UPDATE THE PIXEL ARRAYS
  videoBufferImage.updatePixels();
  bufferImage.updatePixels();
  refImage.updatePixels();
  msk.updatePixels();
  updatePixels(); 
  gSilBuffer.updatePixels();
  gDepthImage.updatePixels();

  //applyMaskToBuffer(msk, bufferImage);

  //OUTPUT BUFFER AND MASK TO THE SCREEN
  tint(255,50);
  image(bufferImage, 0, 0, width, height);
  //image(msk,width*.5,height*.5,width*.5,height*.5);



  /////////////////////////////
  ////DISPLAY VIDEO with slight PERLIN ROTATION
  //CALC NOISE ROTATION
  theta += map(noise(noiseOffset), 0, 1, -maxRot, maxRot);
  noiseOffset += noiseIncrement;
  amountToScale = map(noise(noiseScale), 0, 1, minScale, maxScale);
  noiseScale += noiseScaleIncrement;

  ////////////////////////////////////////
  //DRAW VIDEO LAYER 1
  pushMatrix();
  tint(255, 12);
  imageMode(CENTER);

  translate(width*.5, height*.5);
  rotate(theta);
  scale(amountToScale);

  //////////////////////////////NEEDS THE SILOUETTE VERSION INSTEAD?
  image(video, 0, 0, width, video.height*outputScale); 
  popMatrix();
  ////////////////////////////////////////


  ////////////////////////////////////////
  //DRAW COPY of PREVIOUS FRAME
  pushMatrix();
  tint(255, 15);
  ////////////////////////////
  //prevFrame.copy();  ///////
  ////////////////////////////
  translate(width*.5, height*.5);

  //rotate in the opposite direction from the video layer
  float otherWay = theta*-1;
  rotate(otherWay);

  //scale in the opposite direction from video layer (BROKEN)
  float otherScale = -1*amountToScale*.9;
  scale(otherScale);

  //DRAW PREVIOUS FRAME (shouldn't the frame be copied AFTER this is drawn?)
  image(prevFrame, 0, 0, width, video.height*outputScale);
  applyMaskToBuffer(video, prevFrame);

  popMatrix();
  imageMode(CORNER);
  //prevFrame.copy();
}


// CALLBACK and grab a frame if frames are served
void movieEvent(Movie video) {
  video.read();
}

void updateMaskGraphic() {
  //SETUP THE MASK
  msk.beginDraw();
  msk.background(15);
  msk.fill(255);
  msk.noStroke();
  msk.ellipse(mouseX/outputScale, mouseY/outputScale, 60, 60);
  msk.endDraw();
}

void applyMaskToBuffer(PGraphics _msk, PImage _buffer) {
  //APPLY THE MASK TO THE IMAGE OFFSCREEN -- Formate destinationImage.blend(sourceImage, sourceX, sourceY, sourceW, sourceH, destX, destY, dw, dh, mode)
  _buffer.blend(_msk, 0, 0, _msk.width, _msk.height, 0, 0, _buffer.width, _buffer.height, DARKEST);
}
void applyMaskToBuffer(PImage _msk, PImage _buffer) {
  //APPLY THE MASK TO THE IMAGE OFFSCREEN -- Formate destinationImage.blend(sourceImage, sourceX, sourceY, sourceW, sourceH, destX, destY, dw, dh, mode)
  _buffer.blend(_msk, 0, 0, _msk.width, _msk.height, 0, 0, _buffer.width, _buffer.height, BLEND);//blend//HARD_LIGHT//LIGHTEST
}


void paintWithRandomCirclesFrom() {
  // USE img.get(x,y); when extracting a single pixel value. get() is labor intensive we're not asking for EVERY pixel
  for (int i = 0; i < 1000; i++) {
    // CALC index where index = x + y*refImage.width;
    int x = int(random(refImage.width-1));
    int y = int(random(refImage.height));
    int index =  x + y*refImage.width;
    color c = refImage.pixels[index];
    //float d = dist(float(x), float(y), refImage.width/2, refImage.height/2);
    //float alpha = map(d, 0, 400, 0, 90);
    float alpha = 25;
    fill(c, alpha);
    ellipse(x*outputScale, y*outputScale, 16, 16);
  }
}