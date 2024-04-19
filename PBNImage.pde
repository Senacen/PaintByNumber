PImage pbnImage(PImage inputImg) {
  PImage outputImg = outlineImage(inputImg);
  return outputImg;
}

PImage outlineImage(PImage inputImg) {
  PImage outputImg = inputImg.copy();
  inputImg.loadPixels(); // To calculate outline on
  outputImg.loadPixels(); // To output outline to
  for (int x = 1; x < inputImg.width - 1; x++) {
    for (int y = 1; y < inputImg.height - 1; y++) {
      boolean outline = false;
      int centreIndex = y * inputImg.width + x;
      color centreColour = inputImg.pixels[centreIndex];
      
      // Only outline if top, top left, or left pixel is different to current 
      // If check all neighbours, outlines will be doubled by the pixels on either side of the boundary
      for (int i = -1; outline == false && i <= 0; i++) {
        for (int j = -1; outline == false && j <= 0; j++) {
          int index = (y + j) * inputImg.width + (x + i);
          color colour = inputImg.pixels[index];
          if (colour != centreColour) {
            outline = true;
          }
        }
      }
      outputImg.pixels[centreIndex] = outline ? color(0,0,0) : color(255, 255, 255); // Outline is black, otherwise is white
    }
  }
  inputImg.updatePixels();
  outputImg.updatePixels();
  return outputImg;
}
