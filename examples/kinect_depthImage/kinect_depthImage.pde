import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;


float MAX_THRESH = 970;
float MIN_THRESH = 0;


Kinect kinect;

PImage   gDepthImage;
PImage   gSilBuffer;
PGraphics gDepthBoxBuffer;
int      numOfPreviousDepthImages = 10;
PImage[] gPreviousDepthImages     = new PImage[numOfPreviousDepthImages];
int []   gRawDepth;
int      gPixelSkip               = 1; //cell size when iterating the array

float    gDeg; //set Kinect's viewing angle
boolean  mirror = true;

void setup() {
  size(1024, 768, P3D);
  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.enableMirror(mirror);

  //initialize our PImages
  gSilBuffer = createImage(kinect.width, kinect.height, ARGB);
  gDepthBoxBuffer = createGraphics(kinect.width, kinect.height);
}

void draw() {
  background(0); 

//spotLight(255, 0, 0, width/2, height/2, 400, 0, 0, -1, PI/4, 2);

  //GET RAW DEPTH as an array of intergers (0-2048mm)
  gRawDepth = kinect.getRawDepth();

  //or just get the DEPTH IMAGE
  gDepthImage = kinect.getDepthImage();
  //image(gDepthImage, 0, 0);

  loadPixels();
  gDepthImage.loadPixels();
  gSilBuffer.loadPixels();
  
  
  // EXTRACT A THRESHOLD SILOUETTE AND DRAW IT TO gSilBuffer 
  for (int x = 0; x < kinect.width; x+=gPixelSkip) {
    for (int y = 0; y < kinect.height; y+=gPixelSkip) {
      int index = x + y * kinect.width;
      int depth = gRawDepth[index];  

      ///// TEST AGAINST THRESHOLD
      // if the distance from camera is further than the max threshold, then set that pixel to black
      if ((depth > MAX_THRESH) || (depth < MIN_THRESH)) {
        gSilBuffer.pixels[index] = color(0);
      } else {
        ////////EXTRACT BRIGHTNESS
        float b = map(depth, 200, MAX_THRESH, 255, 10);  //float b = brightness(depth);//brightness(depth);//
        b*=3; //scalar to pump up the brightness
        
        ///////////////////////////
        // 1. EXTRACT RAW DEPTH AND PLACE IT IN gSilBuffer
        gSilBuffer.pixels[index] = color(b);
  
        //   1. extract the raw depth and inform fill and 3D
        //   2. extract a greyscale image and draw it to the gSilBuffer
        
        // EXTRACT RAW DEPTH and DRAW 3D SQUARES
        /*
        float z = map(depth, MIN_THRESH, MAX_THRESH, 400*3, -200); //units along the z axis ////float z = map(b, 0, 255, 250, -250); //units along the z axis
        fill(b);
        pushMatrix();
        translate(x, y, z);
        box(gPixelSkip);
        //rect(0, 0, gPixelSkip, gPixelSkip);
        popMatrix();
        */  
      }
    }
  }
  
  gSilBuffer.updatePixels();
  gDepthImage.updatePixels();
  updatePixels();
  image(gSilBuffer,0,0,width,height);
}


void keyPressed() {
  if (key=='m') {
    mirror = !mirror;
    kinect.enableMirror(mirror);
  } else if (key==CODED) {
    if (keyCode == UP) {
      MAX_THRESH+=5;
      //gDeg++;
    } else if (keyCode == DOWN) {
      MAX_THRESH-=5;
      //gDeg--;
    } else if (keyCode == RIGHT) {
      MIN_THRESH-=5;
    } else if (keyCode == LEFT) {
      MIN_THRESH+=5;
    }
    gDeg = constrain(gDeg, 0, 30);
    kinect.setTilt(gDeg);
  }
  println("MAX_THRESH = " + MAX_THRESH + "    MIN_THRESH = " + MIN_THRESH);
}