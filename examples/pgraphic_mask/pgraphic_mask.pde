PGraphics g;
int x;

void setup(){
  size(720, 480, P2D);
  // create the mask
  g = createGraphics(width,height);
}  

void draw()
{
  background(244,90,10);
  // draw the mask
  g.beginDraw();
  g.background(0);
  g.stroke(255);
  g.line(0, x%height, g.width, x++%height);
  g.endDraw();

  // apply the mask to the screen
  blend(g,0,0, width,height, 0,0,width,height,MULTIPLY);

}