/*
int rgbColourStep = 50;
// rounds the float to the nearest multiple of step, with 255 as the max
int roundToNearest(float a, int step) {
  int multiplier = round(a/step);
  int nearestMultiple = multiplier * step;
  return min(nearestMultiple, 255); // Bound 255 max
}

PImage processImage(PImage inputImg) {
  PImage outputImg = inputImg.copy();
  rgbColourStep = max(1, rgbColourStep);
  rgbColourStep = min(255, rgbColourStep);
  outputImg.loadPixels();
  for (int x = 0; x < outputImg.width; x++) {
    for (int y = 0; y < outputImg.height; y++) {
      int index = y * outputImg.width + x;
      
      // Retrieve original colour
      color originalColour = inputImg.pixels[index];
      float r = originalColour >> 16 & 0xFF;
      float g = originalColour >> 8 & 0xFF;
      float b = originalColour & 0xFF;
      
      // Quantise the colour
      int resultR = roundToNearest(r, rgbColourStep);
      int resultG = roundToNearest(g, rgbColourStep);
      int resultB = roundToNearest(b, rgbColourStep);
      
      // Change the pixel
      outputImg.pixels[index] = color(resultR, resultG, resultB);
    }
  }
  outputImg.updatePixels();
  return outputImg;
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      rgbColourStep++;
      println(rgbColourStep);
      resultImg = processImage(img);
    } 
    else if (keyCode == DOWN) {
      rgbColourStep--;
      println(rgbColourStep);
      resultImg = processImage(img);
    }
    
  }
}
*/
