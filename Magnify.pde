// Magnification settings
boolean magnify = false;
int radius = 60;
int zoomFactor = 2;

void magnify() {
  // Get the sample and zoom it up
  float sampleRadius = float(radius) / zoomFactor;
  PImage sample = get(int(mouseX - sampleRadius), int(mouseY - sampleRadius), int(2 * sampleRadius), int(2 * sampleRadius));
  sample.resize(zoomFactor * sample.width, 0);
  sample.loadPixels();
  
  // Make it a circle
  loadPixels(); // Used to get pixels for transparency
  for (int x = 0; x < sample.width; x++) {
    for (int y = 0; y < sample.height; y++) {
      // displacement from the centre to the pixel
      int deltaX = x - sample.width/2;
      int deltaY = y - sample.height/2;
      // when zoomFactor is odd and radius is not a multiple of zoomFactor, need to correct for off by one error when drawing the outside pixel idk why
      // doesn't work for zoomFactor = 5
      if (zoomFactor % 2 == 1 && radius % zoomFactor != 0) {
        deltaX -= 1;
        deltaY -= 1;
      }
      // If pixel is out of the circle, map it back to the pixel that is behind it to make it transparent
      int distSquared = deltaX * deltaX + deltaY * deltaY;
      if (distSquared >= radius * radius) {
        int index = y * sample.width + x;
        int outsideX = mouseX + deltaX;
        int outsideY = mouseY + deltaY;
        int outsideIndex = outsideY * width + outsideX;
        color c = (outsideIndex >= 0 && outsideIndex < pixels.length) ? pixels[outsideIndex] : color(0,0,0);
        sample.pixels[index] = c; // Black if on radius, transparent if outside
      }
    }
  }
  sample.updatePixels();
  image(sample, mouseX - radius, mouseY - radius);
}
