PImage refImage;
PImage bufferImage;

void setup() {
  //fullScreen(3);
  size(400,400);
  noStroke();

  refImage = loadImage("02.39.00.jpg");
  //refImage.resize(width, height);
  
  bufferImage = createImage(refImage.width, refImage.height, RGB);
  background(0);
}

void draw() {


  for (int i = 0; i < 1000; i++) {
    float x = random(width);
    float y = random(height);
    color c = refImage.get(int(x), int(y));
    fill(c, 55);
    ellipse(x*(width/refImage.width),y*(height/refImage.height),10,10);
    println(400/refImage.width);
    //ellipse(x,y,10,10);
  }
  //image(refImage,0,0);
}