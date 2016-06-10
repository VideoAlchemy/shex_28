import processing.video.*;

Movie video;

void setup(){
  size(640,480);
  video = new Movie(this, "rotaVid.mov");
  video.loop();
}

void movieEvent(Movie video){
 video.read(); 
}

void draw(){
  image(video,0,0);
  //movie.speed(1);
  
}