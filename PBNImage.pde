// Size threshold of region to start labelling
int regionLabelThreshold = 50;

// Precision for finding optimal pole
int precision = 10;

PImage pbnImage(PImage inputImg) {
  //println("reached pbni");
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
  //testImg = inputImg.copy();
  labels = new ArrayList<int[]>();
  filledOutlineImg.loadPixels();
  //testImg.loadPixels();
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
  //println("reached search");
  for (int x = 0; x < filledOutlineImg.width; x++) {
    for (int y = 0; y < filledOutlineImg.height; y++) {
      filledOutlineImg.loadPixels();
      int index = y * filledOutlineImg.width + x;
      color colour = filledOutlineImg.pixels[index];
      //color newColour = color(random(256), random(256), random(256));
      //println(x, y);
      
      
      if (colour != black && colour != white) {
        countRegions++;
        
        // Bounding box init to first pixel
        int leftX = x, topY = y, rightX = x, bottomY = y;
        // Sum of every x and y and the count of the pixels for first guess as the centroid of the region
        int sumX = 0, sumY = 0, countPixels = 0;
        // Push first and mark as processing
        bfs.add(new PVector(x,y));
        filledOutlineImg.pixels[index] = white;
        //println("started bfs");
        
        // Count how many pixels in the region to see if should add label or not
        int regionSize = 0;
        while (!bfs.isEmpty()) {
          PVector top = bfs.remove();
          regionSize++;
          //int topIndex = int(top.y * filledOutlineImg.width + top.x);
          //filledOutlineImg.pixels[topIndex] = newColour;
          countPixels++;
          sumX += top.x;
          sumY += top.y;
          for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
              int neighbourX = int(top.x + i);
              int neighbourY = int(top.y + j);
              int neighbourIndex = neighbourY * filledOutlineImg.width + neighbourX;
              
              // Dont need to check if it's outside the image, as the image is bordered by black
              if (filledOutlineImg.pixels[neighbourIndex] == colour) {
                bfs.add(new PVector(neighbourX, neighbourY));
                // Mark as visited immediately so it doesn't add again
                filledOutlineImg.pixels[neighbourIndex] = white;
                // Update bounding box
                leftX = min(leftX, neighbourX);
                topY = min(topY, neighbourY);
                rightX = max(rightX, neighbourX);
                bottomY = max(bottomY, neighbourY);
                
                //testImg.pixels[neighbourIndex] = newColour;
              }
            }
          }
        }
        //println("ended bfs");
        
        // Calc centroid
        int centroidX = sumX / countPixels;
        int centroidY = sumY / countPixels;
        // Find the pole
        filledOutlineImg.updatePixels();
        
        if (regionSize >= regionLabelThreshold) {
          PVector pole = poleOfInacessibility(filledOutlineImg, precision, leftX, topY, rightX, bottomY, centroidX, centroidY); // 5 pixels distance is the precision to stop searching for improvement
          // Create the label info
          //println("reached adding a label");
          int[] label = new int[4];
          label[0] = int(pole.x);
          label[1] = int(pole.y);
          label[2] = int(pole.z);
          label[3] = palette.indexOf(colour);
          labels.add(label);
        }
        
        
        
        // Mark all those pixels as processed
        filledOutlineImg.loadPixels();
        for (int i = leftX; i <= rightX; i++) {
          for (int j = topY; j <= bottomY; j++) {
            int processedPixelIndex = j * filledOutlineImg.width + i;
            // If it's white, meaning it was being processed, turn it black
            if (filledOutlineImg.pixels[processedPixelIndex] == white) {
              filledOutlineImg.pixels[processedPixelIndex] = black;
            }
          }
        }
        //println("marked all pixels as processed");
        PImage intermediateImg = filledOutlineImg.copy();
        intermediateImg.updatePixels();
        //intermediateImg.save("Saves/intermediateImgProcessed" + countRegions + ".jpg");
        
    }
      
    }
  }
  filledOutlineImg.updatePixels();
  println(countRegions);
  //testImg = filledOutlineImg.copy();
  //println("reached returning all the labels");
  return labels;
}

PVector poleOfInacessibility(PImage filledOutlineImg, int precision, int leftX, int topY, int rightX, int bottomY, int centroidX, int centroidY) {
  //image(filledOutlineImg, 0, 0);
  PriorityQueue<Cell> cellQueue = new PriorityQueue<Cell>(new compareMaxPossibleD());
  
  int regionWidth = rightX - leftX;
  int regionHeight = bottomY - topY;
  
  int minDimension = min(regionWidth, regionHeight);
  // Degenerate case where bounding box is only one pixel wide or tall or 
  if (minDimension == 0) {
    return new PVector(leftX, topY, 0);
  }
  
  int cellSize = minDimension / 4; // How many cells to split the smallest dimension into
  int h = cellSize / 2;
  
  // Degenerate case where cells are too small (caused covering bounding box infinitely)
  if (h == 0) {
    return new PVector(leftX, topY, 0);
  }
  
  // Cover bounding box with cells;
  for (int x = leftX; x <= rightX; x += cellSize) {
    for (int y = topY; y <= bottomY; y += cellSize) {
      cellQueue.add(new Cell(x + h, y + h, h, filledOutlineImg));
    }
  }
  
  // First guess is centroid of the region
  Cell bestCell = new Cell(centroidX, centroidY, 0, filledOutlineImg);
  
  // Second guess is middle of the bounding box
  Cell bboxCell = new Cell(leftX + regionWidth / 2, topY + regionHeight / 2, 0, filledOutlineImg);
  
  // Update best cell if second guess was better
  if (bboxCell.d > bestCell.d) bestCell = bboxCell;
  //println("reached starting the queue");
  while (!cellQueue.isEmpty()) {
    //println(cellQueue.size());
    Cell mostPromising = cellQueue.poll();
    
    // If this solution where the pole is the centre is better, update best cell
    if (mostPromising.d > bestCell.d) {
      bestCell = mostPromising;
    }
    
    // If not possible that a point in the most promising could beat best cell, skip probing
    if (mostPromising.maxPossibleD - bestCell.d <= precision) continue;
    
    // If possible that a point in the most promising could beat best cell, probe further
    h = mostPromising.h / 2;
    if (h <= precision) continue;
    cellQueue.add(new Cell(mostPromising.x - h, mostPromising.y - h, h, filledOutlineImg));
    cellQueue.add(new Cell(mostPromising.x + h, mostPromising.y - h, h, filledOutlineImg));
    cellQueue.add(new Cell(mostPromising.x - h, mostPromising.y + h, h, filledOutlineImg));
    cellQueue.add(new Cell(mostPromising.x + h, mostPromising.y + h, h, filledOutlineImg));
    
  }
  //println("reached return pvector");
  return new PVector(bestCell.x, bestCell.y, bestCell.d);
  
}

class compareMaxPossibleD implements Comparator<Cell> {
  public int compare(Cell a, Cell b) {
    if (a.maxPossibleD < b.maxPossibleD) {
      return 1;
    } else if (a.maxPossibleD > b.maxPossibleD) {
      return -1;
    } else {
      return 0;
    }
  }
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
  
  Cell(int x, int y, int h, PImage filledOutlineImg) {
    this.x = x;
    this.y = y;
    this.h = h;
    radius = sqrt(2) * h;
    
    d = signedDistanceToOutline(x, y, filledOutlineImg);
    //d = 10;
    maxPossibleD = d + radius;
  }
}

float signedDistanceToOutline(int x, int y, PImage filledOutlineImg) {
  
  // If the centre of the cell is outside the image, return a distance of -infinity to discard it
  if (x < 0 || x >= filledOutlineImg.width || y < 0 || y >= filledOutlineImg.height) {
    return -100000000;
  }
  
  //filledOutlineImg.loadPixels();
  int startIndex = y * filledOutlineImg.width + x;
  
  // If the pixels is white, its inside the region
  boolean inside = (filledOutlineImg.pixels[startIndex] == white);
  
  float minDistance = 0;
  
  // Max it'll have to travel is the largest dimension of the img
  //println("start searching for distance");
  for (int i = 1; i < max(filledOutlineImg.width, filledOutlineImg.height); i++) {
    
    int upY = y - i;
    int downY = y + i;
    int leftX = x - i;
    int rightX = x + i;
    
    int upIndex = upY * filledOutlineImg.width + x;
    int downIndex = downY * filledOutlineImg.width + x;
    int leftIndex = y * filledOutlineImg.width + leftX;
    int rightIndex = y * filledOutlineImg.width + rightX;
    
    // If inside, looking for non white
    if (inside) {
      if (upY >= 0 && filledOutlineImg.pixels[upIndex] != white || 
      downY < filledOutlineImg.height && filledOutlineImg.pixels[downIndex] != white || 
      leftX >= 0 && filledOutlineImg.pixels[leftIndex] != white || 
      rightX < filledOutlineImg.width && filledOutlineImg.pixels[rightIndex] != white) {
        minDistance = i;
        break;
      }
    // If outside, looking for white
    } else {
      if (upY >= 0 && filledOutlineImg.pixels[upIndex] == white || 
      downY < filledOutlineImg.height && filledOutlineImg.pixels[downIndex] == white || 
      leftX >= 0 && filledOutlineImg.pixels[leftIndex] == white || 
      rightX < filledOutlineImg.width && filledOutlineImg.pixels[rightIndex] == white) {
        minDistance = i;
        break;
      }
    }
  }
  //println("end searching for distance");
  return minDistance * ((inside) ? 1 : -1);
}
