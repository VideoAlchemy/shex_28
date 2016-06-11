int gDeg;
boolean mirror = true;

float MAX_THRESH = 970;
float MIN_THRESH = 0;

void keyPressed() {
  if (key=='m') {
    mirror = !mirror;
    /*kinect.enableMirror(mirror);*/
  } else if (key=='o') {
    maxRot-= .0002;//.003
  } else if (key=='p') {
    maxRot+= .0002;
  } else if (key=='k') {
    noiseIncrement-= .00005;
  } else if (key=='l') {
    noiseIncrement+= .00005;
  } else if (key=='q') {
    vidSpeed-= .1;
    video.speed(vidSpeed);
  } else if (key=='w') {
    vidSpeed+= .1;
    video.speed(vidSpeed);
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
    /*kinect.setTilt(gDeg);*/
  }
  print("MAX_THRESH:" + MAX_THRESH + " MIN_THRESH:" + MIN_THRESH);
  println("  maxRot:" + maxRot + " noiseIncrement:" + noiseIncrement + "  vidSpeed: " + vidSpeed);
}