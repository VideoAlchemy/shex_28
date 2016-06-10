PImage img;
Pgraphics msk;
//.... do some drawing in both

// apply the mask to the image, both offscreen
img.blend(msk, 0,0,img.height, img.width, 0,0,img.width,img.height,MULTIPLY);
// draw the masked image to the screen
image(img,0,0,width,height);