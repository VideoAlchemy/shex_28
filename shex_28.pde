import processing.video.*;

/*******************************************************************
 * shex_28
 * an interactive installation for Suzan's 28hexadecimal birthday (ie 40)
 * Copyright (c) 2016 Jason Stephens & Video Alchemy Collective
 * The MIT License (MIT)
 *******************************************************************/
/*NOTES:
 - mask sillouettes by either threshold detection in the pixel array OR with BLEND in applyMaskToBuffer function
 */
String  SNAP_FOLDER_PATH       = "../ops-board-snaps/";
PImage refImage;
PImage bufferImage;
PImage prevFrame;
PGraphics buffer;
PGraphics msk;
Movie video;
float outputScale = 1.6;

////////////////SET VID TRANSFORMS
float theta          = 0;
float maxRot         = 0.003;//.003
float noiseOffset    = random(1000);
float noiseIncrement = .003;//.001

float amountToScale  = 0;
float minScale       = 1.4;
float maxScale       = 3;
float noiseScale     = random(40);
float noiseScaleIncrement = .002; //.001

/////////////////////END VIDEO TRANSFORM

void setup() {
  size(1024, 768, P3D);
  //fullScreen(P3D,3);
  
  noStroke();

  //////////////VIDEO
  video = new Movie(this, "rotaVid.mov");
  video.loop();
  /////jump to random location
  //println(video.duration());
  video.jump(random(3000));
  video.speed(.5);//.5,5
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

  /////LOAD THE PIXEL ARRAYS
  loadPixels();
  msk.loadPixels();
  refImage.loadPixels();
  bufferImage.loadPixels();

  for (int x = 0; x < refImage.width; x++) {
    for (int y = 0; y < refImage.height; y++) {
      int index = x + y*refImage.width;


      ////////////////////////////////
      //USE BRIGHTNESS on msk to set equivelant pixel on bufferImage to the color of the refeImage
      //otherwise, make it black
      float pixelBrightnessInMaskImage = brightness(msk.pixels[index]);
      if (pixelBrightnessInMaskImage > 20) {
        bufferImage.pixels[index] = refImage.pixels[index];
      } else {
        bufferImage.pixels[index] = color(0);
      }
      ////////////////////////////////

      float r = red(refImage.pixels[index]);
      float g = green(refImage.pixels[index]);
      float b = blue(refImage.pixels[index]);
      //float d = dist(x,y, refImage.width/2, refImage.height/2);
      //float d = dist(x*outputScale,y*outputScale, mouseX, mouseY);
      //float factor = map(d, 0, 200, 1, -1);

      ///////////////
      //SET bufferImage to refImage
      /////this seems inefficient.  It sets ALL the pixels, then masks out most
      //bufferImage.pixels[index] = color(b,g,r);
    }
  }
  //paintWithRandomCirclesFrom();

  ///////////////////////UPDATE THE PIXEL ARRAYS
  bufferImage.updatePixels();
  refImage.updatePixels();
  msk.updatePixels();
  updatePixels(); 

  //applyMaskToBuffer(msk, bufferImage);

  //OUTPUT TO THE SCREEN
  //image(bufferImage,0,0,width,height);

  ////SHOW MASK
  //image(msk,width*.5,height*.5,width*.5,height*.5);

  /////////////////////////////
  ////DISPLAY VIDEO with slight PERLIN ROTATION
  //CALC NOISE ROTATION
  theta += map(noise(noiseOffset), 0, 1, -maxRot, maxRot);
  noiseOffset += noiseIncrement;
  //CALC NOISE SCALE
  amountToScale = map(noise(noiseScale), 0, 1, minScale, maxScale);
  noiseScale += noiseScaleIncrement;
  tint(255, 12);
  pushMatrix();
  imageMode(CENTER);
  translate(width*.5, height*.5);
  //image(prevFrame, mouseX, mouseY);
  /////////////APPLY PERLIN TO ROTATION and SCALE
  rotate(theta);
  scale(amountToScale);
  //applyMaskToBuffer(video, prevFrame);


  //////////////////////////////////////// 
  //keep video.height to retain aspect ratio. the DV conversion to 640x480 turned it to 640x370. Without the outputscale on y, we'd get ovals
  image(video, 0, 0, width, video.height*outputScale); 
  //scale(amountToScale/2);
  popMatrix();
  //prevFrame = copy();
  tint(255, 15);

  //scale();
  pushMatrix();
  prevFrame = copy();
  translate(width*.5, height*.5);
  //rotate(2*PI);
  //rotateX(PI);
  float otherWay = theta*-1;
  rotate(otherWay);
  float otherScale = -1*amountToScale*.9;
  scale(otherScale);
  image(prevFrame, 0, 0,width, video.height*outputScale);
  applyMaskToBuffer(video, prevFrame);
  ////RESET imageMODE to default

  popMatrix();

  imageMode(CORNER);
  /*
  ////////DRAW PREVIOUS FRAME
   pushMatrix();
   imageMode(CENTER);
   translate(width*.5, height*.5);
   //translate(mouseX, mouseY);
   tint(255,25);
   scale(amountToScale*.5);
   rotate(PI);
   rotateX(PI);
   rotate(-theta*2);
   image(prevFrame, 0,0);
   
   
   //scale(amountToScale*.5);
   
   imageMode(CORNER);
   popMatrix();
   */
  //////////PREVIOUS FRAME
  //END VIDEO DISPLAY
  ////////////////////////////////
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
  _buffer.blend(_msk, 0, 0, _msk.width, _msk.height, 0, 0, _buffer.width, _buffer.height, HARD_LIGHT);//blend//HARD_LIGHT//LIGHTEST
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