//PGraphics example
//  loop animation with an array of PGraphics
//  http://funprogramming.org/144-Drawing-animated-loops.html

int frames = 20;
PGraphics pg[] = new PGraphics[frames];
PGraphics baseLayer;

void setup() {
  size(500, 500, P2D);
  baseLayer = createGraphics(width, height);
   baseLayer.beginDraw();
    baseLayer.background(0);
    baseLayer.stroke(255);
    baseLayer.strokeWeight(3);
    baseLayer.endDraw();
  
  for(int i=0; i<frames; i++) {
    pg[i] = createGraphics(width, height);
    pg[i].beginDraw();
    pg[i].background(0);
    pg[i].stroke(255);
    pg[i].strokeWeight(3);
    pg[i].endDraw();
  }
}
void draw() {
  int currFrame = frameCount % frames; // 0 .. 19
  if(mousePressed) {
    pg[currFrame].beginDraw();
    pg[currFrame].line(mouseX, mouseY, pmouseX, pmouseY);
    pg[currFrame].endDraw();
  
  }
    
    baseLayer.beginDraw();
    baseLayer.blendMode(DIFFERENCE);
    //baseLayer.ellipse(mouseX,mouseY,10,10);
    baseLayer.image(pg[currFrame],0, 0);
    baseLayer.endDraw();
  
  //blendMode(SOFT_LIGHT);
  /*
  for (int i = 0; i < 17; i++){
    pg[17-i].beginDraw();
    //draw each frame into current Frame 
    pg[17-i].image(pg[currFrame], 0, 0);
    pg[17-i].endDraw();
  }
  */
  
  //image(pg[currFrame], 0, 0);
  image(baseLayer, 0, 0);
}