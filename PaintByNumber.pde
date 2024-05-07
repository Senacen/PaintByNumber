import java.util.Comparator;
import java.util.PriorityQueue;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Calendar;
import java.text.SimpleDateFormat;

// Images
PImage img;
PImage resultImg;
PImage paintByNumberImg;
PImage paletteImg;

// Image resize dimensions
int imgResizeWidth = 1000; // only width, as height has to be scaled proportionally
int paletteImgResizeWidth = 1000;
int paletteImgResizeHeight = 500;

// Palette draw settings
int paletteRectWidth = 50;
int paletteRectSpacing = 50; // Spacing between palette rects, and between palette rects and the borders of the palette
int paletteRectRadius = 0; // Smooths the corners

ArrayList<Integer> palette; // requires Integer class, as color is a primitive
ArrayList<Integer> paintCounts; // To calculate how much of the picture uses the paint

// Selection rectangle for selective blurring variables
int startX, startY, endX, endY;
boolean dragging = false;

// Colour constants reserved
color black = color(0, 0, 0); // Outline
//color black = color(128, 128, 128); // Outline
color white = color(255, 255, 255); // Processing
boolean blackAndWhiteMode = false;

// Label Locations
ArrayList<int[]> labels;
int minLabelSize = 10;
int maxLabelSize = 50;
boolean labelling = false;

// Palette bounds for saving
int paletteLeftX;
int paletteRightX;
int paletteTopY;
int paletteBottomY;


void settings() {
  String imgFile = "face.jpg";
  //String imgFile = "colour wheel.png";
  //String imgFile = "hill.jpg";
  //String imgFile = "big hill.jpg";
  //String imgFile = "squares.png";
  //String imgFile = "mayflower.jpg";
  //String imgFile = "holloway.jpg";
  //String imgFile = "raze.jpg";
  //String imgFile = "artAutumn.jpg";
  
  img = loadImage("Images/" + imgFile);
  img.resize(imgResizeWidth, 0);
  resultImg = img.copy();
  paintByNumberImg = createImage(img.width, img.height, RGB);
  
  //String paletteImgFile = "pencils.jpg";
  String paletteImgFile = "fullPaints.jpg";
  //String paletteImgFile = "colour wheel.png";
  //String paletteImgFile = "palette.jpg";
  //String paletteImgFile = "raze.jpg";
  //String paletteImgFile = "face.jpg";
  //String paletteImgFile = "PBNifyTestPalette.png";
  //String paletteImgFile = "mayflower.jpg";
  //String paletteImgFile = "paints.jpg";
  paletteImg = loadImage("Images/" + paletteImgFile);
  paletteImg.resize(paletteImgResizeWidth, paletteImgResizeHeight);
  size(img.width + resultImg.width + img.width, img.height + paletteImg.height);
}

void setup() {
  // Startup location
  surface.setLocation(0, 0);
  palette = new ArrayList<Integer> (); //<>//
  resultImg = colourImage(img);
  paintByNumberImg = pbnImage(resultImg);
}


void mouseClicked() {
  // Add paints with left click
  // If the mouse is on the palette image
  if (mouseButton == LEFT && mouseX < paletteImg.width && mouseY > img.height) { 
    int x = mouseX;
    int y = mouseY - img.height;
    paletteImg.loadPixels();
    int index = y * paletteImg.width + x;
    color colourToAdd = paletteImg.pixels[index];
    // Check the colour isn't reserved or already in the palette
    if (colourToAdd != black && colourToAdd != white && !palette.contains(Integer.valueOf(colourToAdd))) {
      palette.add(colourToAdd);
    }
    paletteImg.updatePixels();
    resultImg = colourImage(img);
    paintByNumberImg = pbnImage(resultImg);
  }
  // Remove paints with right click
  // If the mouse is on the palette image, palette area or on the result image
  if (mouseButton == RIGHT && (mouseY > img.height 
  || mouseX > img.width && mouseX < img.width + resultImg.width && mouseY < resultImg.height)) { 
    loadPixels();
    int index = mouseY * width + mouseX;
    color colorToRemove = pixels[index];
    palette.remove(Integer.valueOf(colorToRemove)); // Does nothing if colour is not in the palette
    updatePixels();
    resultImg = colourImage(img);
    paintByNumberImg = pbnImage(resultImg);
  }
  
}

void keyPressed() {
  // smooths the image with space
  if (key == ' ') {
    resultImg = smoothImage(resultImg, 0, 0, resultImg.width, resultImg.height);
    paintByNumberImg = pbnImage(resultImg);
  } else if (key == 'm'){
    magnify = !magnify;
  } else if (key == 's'){
    saveImages();
    println("saved");
  } else if (key == 'r'){
    resultImg = colourImage(img);
    paintByNumberImg = pbnImage(resultImg);
  } else if (key == 'l'){
    labelling = !labelling;
    // Don't recalculate resultImg as that will ignore smoothing
    paintByNumberImg = pbnImage(resultImg);
  } else if (key == 'b'){
    blackAndWhiteMode = !blackAndWhiteMode;
    // Don't recalculate resultImg as that will ignore smoothing
    paintByNumberImg = pbnImage(resultImg);
  } else if (key == CODED) {
    if (keyCode == UP) {
      blurKernelSize += 2;
    }
    if (keyCode == DOWN) {
      blurKernelSize -= 2;
    }
    if (blurKernelSize < 3) blurKernelSize = 3;
    if (blurKernelSize >= min(resultImg.width, resultImg.height)) blurKernelSize = min(resultImg.width, resultImg.height);
  }
}

// Store start pos
void mousePressed() {
  if (mouseButton == LEFT) {
    dragging = false;
    startX = mouseX;
    startY = mouseY;
  }
  
}
// Draw current rectangle
void mouseDragged() {
  if (mouseButton == LEFT) {
    dragging = true;
    endX = mouseX;
    endY = mouseY;
  }
  
}
// If dragged, blur selected rectangle
void mouseReleased() {
  if (dragging) {
    dragging = false;
    // Coords of rectangle
    int leftX = min(startX, endX);
    int topY = min(startY, endY);
    int rightX = max(startX, endX);
    int bottomY = max(startY, endY);
    
    // Coords of resultImgn with some padding to avoid out of range errors for sure
    int resultImgLeftX = img.width + 1;
    int resultImgTopY = 0;
    int resultImgRightX = img.width + resultImg.width - 1;
    int resultImgBottomY = img.height - 1;

    // If none of the rectangle is on the resultImg, break
    if (leftX >= resultImgRightX || topY >= resultImgBottomY || rightX <= resultImgLeftX || bottomY <= resultImgTopY) return;
    
    // Bound the rectangle to inside resultImg
    leftX = max(leftX, resultImgLeftX);
    topY = max(topY, resultImgTopY);
    rightX = min(rightX, resultImgRightX);
    bottomY = min(bottomY, resultImgBottomY);

    // If the width or height of this bounded rectangle are too small for the blur kernel size, break
    if (rightX - leftX <= blurKernelSize || bottomY - topY <= blurKernelSize) return;
    resultImg = smoothImage(resultImg, leftX, topY, rightX, bottomY);
    paintByNumberImg = pbnImage(resultImg);
  }
  
}


void draw() {
  background(255);
  //image(blurImage(img, 0, 0, img.width, img.height), 0, 0);
  image(img, 0, 0);
  image(resultImg, img.width, 0);
  image(paintByNumberImg, img.width + resultImg.width, 0);
  image(paletteImg, 0, img.height);
  //Reset palette bounds
  paletteLeftX = width;
  paletteRightX = 0;
  paletteTopY = height;
  paletteBottomY = 0;
  drawPalette();
  surface.setTitle("Paint By Number - " + "Blur Kernel Size: " + blurKernelSize + " - Frame Rate: " + round(frameRate));
  
   textAlign(CENTER, CENTER);
   fill(0);
   
  // Draw labels
  if (labelling) {
    for (int[] label : labels) {
      int labelSize = max(label[2], minLabelSize);
      labelSize = min(labelSize, maxLabelSize);
      textSize(labelSize); // set size to be proportional to the max distance
      fill((blackAndWhiteMode) ? black : palette.get(label[3])); // If black and white mode, label will be black, if colour mode, label will the colour of the region
      text(label[3] + 1, img.width + resultImg.width + label[0], label[1]);
    }
  }
  
  // Draw selection rectangle
  if (dragging) {
    fill(255, 255, 255, 50);
    int leftX = min(startX, endX);
    int topY = min(startY, endY);
    int rectWidth = abs(startX - endX);
    int rectHeight = abs(startY - endY);
    rect(leftX, topY, rectWidth, rectHeight);
  
  }
  
  // If magnify, turn on magnification
  if (magnify) {
    magnify();
  }
  
}


void drawPalette() {
  stroke(1);
  // Draw current palette
  int row = 0;
  int column = 0;
  for (int i = 0; i < palette.size(); i++) {
    color paint = palette.get(i);
    fill(paint);
    int spacing = paletteRectSpacing;
    int rectWidth = paletteRectWidth;
    int x = paletteImg.width + spacing * (column + 1) + rectWidth * column;
    // If offscreen, start a new row
    if (x + rectWidth + spacing > width) {
      row++;
      column = 0;
      // Recalculate for new row
      x = paletteImg.width + spacing * (column + 1) + rectWidth * column;
    }
    int y = img.height + spacing * (row + 1) + rectWidth * row;
    rect(x, y, rectWidth, rectWidth, paletteRectRadius);
    
    // Update bounds if necessary for save
    paletteLeftX = min(paletteLeftX, x);
    paletteRightX = max(paletteRightX, x + rectWidth); // Add rectWidth to find right side, as x is the left corner
    paletteTopY = min(paletteTopY, y);
    paletteBottomY = max(paletteBottomY, y + rectWidth); // Add rectWidth to find bottom side, as y is the top corner
    
    // Draw the number of the paint
    textAlign(CENTER, CENTER);
    fill((brightness(paint) > 240) ? 0 : 255); // Set text color to black if paint is light, white if paint is dark. 240 is threshold found by trial and error
    textSize(rectWidth / 2); // Adjust text size to fit inside the rectangle
    text(i + 1, x + rectWidth / 2, y + rectWidth / 2); // Draw index in the middle
    
    // Draw the percentage of the painting it makes up
    fill(0);
    textSize(rectWidth / 4);
    float percentage = (paintCounts.get(i)  * 100f) / (resultImg.width * resultImg.height);
    // Round percentage to nearest decimal point
    String roundedPercentage = String.format("%.1f", percentage);
    text(roundedPercentage + "%", x + rectWidth / 2, y + rectWidth + spacing / 4);
    
    column++;
  }
  noStroke();
}
