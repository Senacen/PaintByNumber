// Size threshold of region to start labelling
int regionLabelThreshold = 50;

// Precision for finding optimal pole, when is too small can mess up small cells
int precision = 1;

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
      //filledOutlineImg.loadPixels();
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
        //filledOutlineImg.updatePixels();
        
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
        //filledOutlineImg.loadPixels();
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
  //filledOutlineImg.updatePixels();
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
  // Degenerate case where bounding box is only one pixel wide or tall just return centroid
  if (minDimension == 0) {
    return new PVector(centroidX, centroidY, 0);
  }
  
  int cellSize = minDimension / 4; // How many cells to split the smallest dimension into
  int h = cellSize / 2;
  
  // Degenerate case where cells are too small (caused covering bounding box infinitely) just return centroid
  if (cellSize == 0) {
    return new PVector(centroidX, centroidY, 0);
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
  // If the center of the cell is outside the image, return a distance of -infinity to discard it
  if (x < 0 || x >= filledOutlineImg.width || y < 0 || y >= filledOutlineImg.height) {
    return -100000000;
  }

  // If the pixel is white, it's inside the region
  boolean inside = (filledOutlineImg.pixels[y * filledOutlineImg.width + x] == white);

  float minDistance = 0;

  // Search for the minimum distance in all directions
  for (int i = 1; i < max(filledOutlineImg.width, filledOutlineImg.height); i++) {
    // Check all eight neighboring pixels (diagonals included)
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        boolean diagonal = (dx != 0 && dy != 0); // True if currently diagonal direction, false if cardinal
        if (dx == 0 && dy == 0) continue; // Skip the center pixel
        //if (diagonal) continue;
        
        int nx = x + dx * i;
        int ny = y + dy * i;
        
         if (diagonal) {
          nx = x + round((dx * i) / sqrt(2));
          ny = y + round((dy * i) / sqrt(2));
        }

        // If the neighboring pixel is outside the image, skip
        if (nx < 0 || nx >= filledOutlineImg.width || ny < 0 || ny >= filledOutlineImg.height) continue;

        int nIndex = ny * filledOutlineImg.width + nx;

        // If inside, looking for non-white
        if (inside) {
          if (filledOutlineImg.pixels[nIndex] != white) {
            minDistance = i;
            return minDistance;
          }
        } else { // If outside, looking for white
          if (filledOutlineImg.pixels[nIndex] == white) {
            minDistance = i;
            return minDistance * -1;
          }
        }
      }
    }
  }

  return minDistance * ((inside) ? 1 : -1);
}
