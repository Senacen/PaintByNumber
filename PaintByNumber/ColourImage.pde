PImage colourImage(PImage inputImg) {
  PImage outputImg = inputImg.copy();
  outputImg.loadPixels();
  for (int x = 0; x < outputImg.width; x++) {
    for (int y = 0; y < outputImg.height; y++) {
      int index = y * outputImg.width + x;
      
      // Retrieve original colour
      color originalColour = inputImg.pixels[index];
      float originalR = red(originalColour);
      float originalG = green(originalColour);
      float originalB = blue(originalColour);
      
      // Find the closest paint in the palette
      color closestColour = color(0,0,0); // Initialise to avoid compiler error
      float minDistanceSquared = redmeanSquared(0, 255, 0, 255, 0, 255); // Max square distance of redmean possible, diff between white and black
      for (int i = 0; i < palette.size(); i++) {
        color paint = palette.get(i);
        float paintR = red(paint);
        float paintG = green(paint);
        float paintB = blue(paint);
        
        // Euclidean distance
        //float distance = (r - paintR) * (r - paintR) + (b - paintB) * (b - paintB) + (g - paintG) * (g - paintG);
        
        // Redmean distance
        float distanceSquared = redmeanSquared(originalR, paintR, originalG, paintG, originalB, paintB);
        if (distanceSquared < minDistanceSquared) {
          minDistanceSquared = distanceSquared;
          closestColour = paint;
        }
      }
      
      // Change the pixel to that paint
      outputImg.pixels[index] = closestColour;
    }
  }
  outputImg.updatePixels();
  return outputImg;
}

float redmeanSquared(float r1, float r2, float g1, float g2, float b1, float b2) {
  float redmean = (r1 + r2) / 2;
  float deltaR = r2 - r1;
  float deltaG = g2 - g1;
  float deltaB = b2 - b1;
  float deltaColour = (2 + redmean/256) * deltaR*deltaR + 4 * deltaG*deltaG + (2 + (255 - redmean)/256) * deltaB*deltaB;
  return deltaColour;
}
