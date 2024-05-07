// Smooth settings
int blurKernelSize = 5;

PImage smoothImage(PImage inputImg, int startX, int startY, int endX, int endY) {
  PImage outputImage = blurImage(inputImg, startX, startY, endX, endY);
  outputImage = colourImage(outputImage);
  return outputImage;
}

// Changes inputImg in current implementation
// Uses sliding window an a combination of two 1D box blurs to create a 2D box blur in lower time complexity
PImage blurImage(PImage inputImg, int startX, int startY, int endX, int endY) {
  PImage outputImg = inputImg.copy();
  inputImg.loadPixels(); // To calculate blur on
  outputImg.loadPixels(); // To output blurred pixel to
  
  // two passes of 1D box blur
  float weight = 1f / blurKernelSize;
  int boundary = (blurKernelSize - 1) / 2;
  
  // Horizontal Pass (will blur vertical extremes just horizontally, as they will be outside the kernel size for vertical)
  for (int y = startY; y < endY; y++) {
    // Initialise the sliding window
    float rSum = 0;
    float gSum = 0;
    float bSum = 0;
    for (int i = startX; i < startX + blurKernelSize; i++) {
      int index = y * inputImg.width + i;
      color colour = inputImg.pixels[index];
      float r = red(colour);
      float g = green(colour);
      float b = blue(colour);
      rSum += r;
      gSum += g;
      bSum += b;
    }
    
    for (int x = startX + boundary + 1; x < endX - boundary; x++) {
      
      // Adding new pixel in sliding window
      int rightIndex = y * inputImg.width + (x + boundary);
      color colour = inputImg.pixels[rightIndex];
      float r = red(colour);
      float g = green(colour);
      float b = blue(colour);
      rSum += r;
      gSum += g;
      bSum += b;
      
      // Subtracting oldest pixel in sliding window
      int leftIndex = y * inputImg.width + (x - boundary - 1);
      colour = inputImg.pixels[leftIndex];
      r = red(colour);
      g = green(colour);
      b = blue(colour);
      rSum -= r;
      gSum -= g;
      bSum -= b;
        
      int centreIndex = y * inputImg.width + x;
      outputImg.pixels[centreIndex] = color(rSum * weight, gSum * weight, bSum * weight);
    }
  }
  
  // Change inputImg to the blurred first pass
  inputImg = outputImg.copy();
  
  // Vertical Pass (will blur horizontal extremes just vertically, as they will be outside the kernel size for horizontal)
  for (int x = startX; x < endX; x++) {
    // Initialise the sliding window
    float rSum = 0;
    float gSum = 0;
    float bSum = 0;
    for (int i = startY; i < startY + blurKernelSize; i++) {
      int index = i * inputImg.width + x;
      color colour = inputImg.pixels[index];
      float r = red(colour);
      float g = green(colour);
      float b = blue(colour);
      rSum += r;
      gSum += g;
      bSum += b;
    }
    for (int y = startY + boundary + 1; y < endY - boundary; y++) {
      
      // Adding new pixel in sliding window
      int downIndex = (y + boundary) * inputImg.width + x;
      color colour = inputImg.pixels[downIndex];
      float r = red(colour);
      float g = green(colour);
      float b = blue(colour);
      rSum += r;
      gSum += g;
      bSum += b;
      
      // Subtracting oldest pixel in sliding window
      int upIndex = (y - boundary - 1) * inputImg.width + x;
      colour = inputImg.pixels[upIndex];
      r = red(colour);
      g = green(colour);
      b = blue(colour);
      rSum -= r;
      gSum -= g;
      bSum -= b;
        
      int centreIndex = y * inputImg.width + x;
      outputImg.pixels[centreIndex] = color(rSum * weight, gSum * weight, bSum * weight);
    }
  }

  inputImg.updatePixels();
  outputImg.updatePixels();
  return outputImg;
}
