import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;


Kinect kinect;
PImage depthImage;

float deg; //set Kinect's viewing angle

boolean mirror = false;

void setup() {
  size(640, 480, P3D);
  kinect = new Kinect(this);
  kinect.initDepth();
}

void draw() {
  background(0); 

  //GET RAW DEPTH as an array of intergers (0-2048mm)
  int[] depth = kinect.getRawDepth();

  //or just get the DEPTH IMAGE
  depthImage = kinect.getDepthImage();
  //image(depthImage, 0, 0);
  
  int skip = 20; //cell size to divide the depthImage
  
  for (int x = 0; x < depthImage.width; x+=skip){
     for (int y = 0; y < depthImage.height; y+=skip) {
       int index = x + y * depthImage.width;
       float b = brightness(depthImage.pixels[index]);
       float z = map(b, 0,255,150,-150); //units along the z axis
       fill(255-b);
       pushMatrix();
       translate(x,y,z);
       rect(0,0,skip/2,skip/2);
       popMatrix();
     }
  }
}


void keyPressed() {
  if (key=='m') {
    mirror = !mirror;
    kinect.enableMirror(mirror);
  } else if (key==CODED) {
    if (keyCode == UP) {
      deg++;
    } else if (keyCode == DOWN) {
      deg--;
    }
    deg = constrain(deg,0,30);
    kinect.setTilt(deg);
  }
}