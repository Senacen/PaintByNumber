// Smooth settings
int blurKernelSize = 5;

PImage smoothImage(PImage inputImg) {
  PImage outputImage = blurImage(inputImg);
  outputImage = colourImage(outputImage);
  return outputImage;
}

// Changes inputImg in current implementation
// Uses sliding window an a combination of two 1D box blurs to create a 2D box blur in lower time complexity
PImage blurImage(PImage inputImg) {
  PImage outputImg = inputImg.copy();
  inputImg.loadPixels(); // To calculate blur on
  outputImg.loadPixels(); // To output blurred pixel to
  
  // two passes of 1D box blur
  float weight = 1f / blurKernelSize;
  int boundary = (blurKernelSize - 1) / 2;
  
  // Horizontal Pass
  for (int y = boundary; y < inputImg.height - boundary; y++) {
    // Initialise the sliding window
    float rSum = 0;
    float gSum = 0;
    float bSum = 0;
    for (int i = 0; i < blurKernelSize; i++) {
      int index = y * inputImg.width + i;
      color colour = inputImg.pixels[index];
      float r = red(colour);
      float g = green(colour);
      float b = blue(colour);
      rSum += r;
      gSum += g;
      bSum += b;
    }
    
    for (int x = boundary + 1; x < inputImg.width - boundary; x++) {
      
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
  
  // Vertical Pass
  for (int x = boundary; x < inputImg.width - boundary; x++) {
    // Initialise the sliding window
    float rSum = 0;
    float gSum = 0;
    float bSum = 0;
    for (int i = 0; i < blurKernelSize; i++) {
      int index = i * inputImg.width + x;
      color colour = inputImg.pixels[index];
      float r = red(colour);
      float g = green(colour);
      float b = blue(colour);
      rSum += r;
      gSum += g;
      bSum += b;
    }
    for (int y = boundary + 1; y < inputImg.height - boundary; y++) {
      
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


/*PImage blurImage(PImage inputImg) {
  PImage outputImg = inputImg.copy();
  inputImg.loadPixels(); // To calculate blur on
  outputImg.loadPixels(); // To output blurred pixel to
  
  float[][] kernel = blurKernel();
  int boundary = (blurKernelSize - 1) / 2;
  
  for (int x = boundary; x < inputImg.width - boundary; x++) {
    for (int y = boundary; y < inputImg.height - boundary; y++) {
      float convolutedR = 0;
      float convolutedB = 0;
      float convolutedG = 0;
      for (int i = -boundary; i <= boundary; i++) {
        for (int j = -boundary; j <= boundary; j++) {
          int index = (y + j) * inputImg.width + (x + i);
          color colour = inputImg.pixels[index];
          float r = red(colour);
          float g = green(colour);
          float b = blue(colour);
          float weight = kernel[boundary + i][boundary + j];
          convolutedR += r * weight;
          convolutedG += g * weight;
          convolutedB += b * weight;
        }
      }
      int centreIndex = y * inputImg.width + x;
      outputImg.pixels[centreIndex] = color(convolutedR, convolutedG, convolutedB);
    }
  }
  
  inputImg.updatePixels();
  outputImg.updatePixels();
  return outputImg;
}
*/

/*float[][] blurKernel() {
  float v = 1f / (blurKernelSize * blurKernelSize);
  float[][] res = new float[blurKernelSize][blurKernelSize];
  for (int i = 0; i < blurKernelSize; i++) {
    for (int j = 0; j < blurKernelSize; j++) {
      res[i][j] = v;
    }
  }
  return res;
}*/
