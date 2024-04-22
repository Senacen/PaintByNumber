import java.util.Queue;
import java.util.LinkedList;

PImage pbnImage(PImage inputImg) {
  PImage outputImg = outlineImage(inputImg);
  labels = calculateLabels(outputImg);
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

// Input img is just the outline
ArrayList<int[]> calculateLabels(PImage inputImg) {
  PImage filledOutlineImg = resultImg.copy();
  testImg = inputImg.copy();
  labels = new ArrayList<int[]>();
  filledOutlineImg.loadPixels();
  testImg.loadPixels();
  resultImg.loadPixels();
  
  // Combine the outline and the filled colours
  for (int x = 0; x < filledOutlineImg.width; x++) {
    for (int y = 0; y < filledOutlineImg.height; y++) {
      int index = y * filledOutlineImg.width + x;
      color colour = inputImg.pixels[index];
      if (colour == black) {
        filledOutlineImg.pixels[index] = black;
      }
    }
  }
  
  // Create bfs once and reuse
  Queue<PVector> bfs = new LinkedList<>();
  int countRegions = 0;
  for (int x = 0; x < filledOutlineImg.width; x++) {
    for (int y = 0; y < filledOutlineImg.height; y++) {
      int index = y * filledOutlineImg.width + x;
      color colour = filledOutlineImg.pixels[index];
      color newColour = color(random(256), random(256), random(256));
      //println(x, y);
      
      
      if (colour != black) {
        countRegions++;
        
        // Push first and mark as visited
        bfs.add(new PVector(x,y));
        filledOutlineImg.pixels[index] = black;
        while (!bfs.isEmpty()) {
          PVector top = bfs.remove();
          int topIndex = int(top.y * filledOutlineImg.width + top.x);
          filledOutlineImg.pixels[topIndex] = black;
          //filledOutlineImg.pixels[topIndex] = newColour;
          for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
              int neighbourX = int(top.x + i);
              int neighbourY = int(top.y + j);
              int neighbourIndex = neighbourY * filledOutlineImg.width + neighbourX;
              
              // Dont need to check if it's outside the image, as the image is bordered by black
              if (filledOutlineImg.pixels[neighbourIndex] == colour) {
                bfs.add(new PVector(neighbourX, neighbourY));
                // Mark as visited immediately so it doesn't add again
                filledOutlineImg.pixels[neighbourIndex] = black;
                testImg.pixels[neighbourIndex] = newColour;
              }
            }
          }
          
        }
      }
      
    }
  }
  filledOutlineImg.updatePixels();
  println(countRegions);
  //testImg = filledOutlineImg.copy();
  return labels;
}

class Cell {
  // Centre coords
  int x;
  int y;
  
  // Half the size
  int h;
  
  // Square diagonal
  float radius;
  
  // Signed distance from centre to outline
  float d;
  
  // Max possible d for a point in the cell
  float maxPossibleD;
  
  Cell(int x, int y, int h) {
    radius = sqrt(2) * h;
  }
}
