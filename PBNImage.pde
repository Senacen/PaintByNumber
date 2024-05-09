PImage pbnImage(PImage inputImg) {
  sortPalette(); // This is always called when the colours have changed, either from smooth or colour image
  //println("reached pbni");
  PImage outputImg = outlineImage(inputImg);
  if (labelling) {
    labels = calculateLabels(outputImg);
  }
  if (!blackAndWhiteMode) {
    outputImg = colourOutlineImage(outputImg);
  }
  return outputImg;
}

PImage outlineImage(PImage inputImg) {
  PImage outputImg = inputImg.copy();
  inputImg.loadPixels(); // To calculate outline on
  outputImg.loadPixels(); // To output outline to
  for (int x = 0; x < inputImg.width; x++) {
    for (int y = 0; y < inputImg.height; y++) {
      boolean outline = false;
      int centreIndex = y * inputImg.width + x;
      color centreColour = inputImg.pixels[centreIndex];
      
      // Make borders outlined
      if (x == 0 || y == 0 || x == inputImg.width - 1 || y == inputImg.height - 1) {
        outline = true;
      }
      
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
      outputImg.pixels[centreIndex] = outline ? black : white; // Outline is black, otherwise is white
    }
  }
  inputImg.updatePixels();
  outputImg.updatePixels();
  return outputImg;
}

PImage colourOutlineImage(PImage inputImg) {
  PImage outputImg = inputImg.copy();
  inputImg.loadPixels();
  outputImg.loadPixels(); // To output coloured outline to
  resultImg.loadPixels(); // To calculate colour from
  
  // Skip borders and leave them black
  for (int x = 1; x < inputImg.width - 1; x++) {
    for (int y = 1; y < inputImg.height - 1; y++) {
       int index = y * inputImg.width + x;
       if (inputImg.pixels[index] == black) {
         
         float rSum = 0f;
         float gSum = 0f;
         float bSum = 0f;
         
         for (int dx = -1; dx <= 1; dx++) {
           for (int dy = -1; dy <= 1; dy++) {
             int nx = x + dx;
             int ny = y + dy;
             
             int nIndex = ny * inputImg.width + nx;
             rSum += red(resultImg.pixels[nIndex]);
             gSum += green(resultImg.pixels[nIndex]);
             bSum += blue(resultImg.pixels[nIndex]);
           }
         }
         float rAvg = rSum / 9;
         float gAvg = gSum / 9;
         float bAvg = bSum / 9;
         outputImg.pixels[index] = color(rAvg, gAvg, bAvg);
         //outputImg.pixels[index] = resultImg.pixels[index]; // If want to just take the centre pixel
       }
    }
  }
  outputImg.updatePixels();
  return outputImg;
}
