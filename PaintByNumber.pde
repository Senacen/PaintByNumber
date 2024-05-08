import java.util.Comparator;
import java.util.PriorityQueue;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Calendar;
import java.text.SimpleDateFormat;
import java.util.Collections;

// Images
PImage img;
PImage resultImg;
PImage paintByNumberImg;
PImage paletteImg;

// Image Paths
String imgPath;
String paletteImgPath;

boolean running; // Used so draw does nothing until images are loaded, or images have been loaded and a new one is being selected

// Image resize dimensions
int imgResizeWidth = 800; // only width, as height has to be scaled proportionally
int paletteImgResizeWidth = 1000;
int paletteImgResizeHeight = 500;

// Palette draw settings
int paletteRectWidth = 50;
int paletteRectSpacing = 50; // Spacing between palette rects, and between palette rects and the borders of the palette
int paletteRectRadius = 0; // Smooths the corners

ArrayList<Integer> palette; // requires Integer class, as color is a primitive
ArrayList<Integer> paintCounts; // To calculate how much of the picture uses the paint
ArrayList<Integer[]> paletteWithCounts; // To sort both palette and paintCounts by the count

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


// Very messy calls to make sure the selectInput functions are completed before continuing
// Normally, they are in external threads and therefore without chaining the functions, 
// we try and fail to create the PImages before the files are chosen
void setup() {
  size(0,0);
  surface.setLocation(0, 0);
  initialiseImages();
}

void initialiseImages() {
  selectInput("Select the input image you wish to turn into a Paint by Number: ", "inputImgSelected"); 
}

void inputImgSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    if (!running) exit(); // If no image has been loaded now or previously, exit the program. 
    // If it has been running, cancelling just returns the user back to their original images
  } else {
    imgPath = selection.getAbsolutePath(); // Store the image path, but don't create the image unless both input and palette images are succesfully selected
    selectInput("Select the palette image you wish to pick your palette from: ", "paletteImgSelected");
  }
}

void paletteImgSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    if (!running) exit(); // If no image has been loaded now or previously, exit the program. 
    // If it has been running, cancelling just returns the user back to their original images
  } else {
    // Both input and palette images have been succesfully selected, so create them.
    img = loadImage(imgPath);
    img.resize(imgResizeWidth, 0);
    resultImg = img.copy();
    paintByNumberImg = createImage(img.width, img.height, RGB);
    paletteImgPath = selection.getAbsolutePath();
    paletteImg = loadImage(paletteImgPath);
    paletteImg.resize(paletteImgResizeWidth, paletteImgResizeHeight);
    
    // Reset variables back
    initialiseVariables();
  }
}

void initialiseVariables() {
  surface.setSize(img.width + resultImg.width + img.width, img.height + paletteImg.height);
  palette = new ArrayList<Integer> ();
  resultImg = colourImage(img);
  paintByNumberImg = pbnImage(resultImg);
  running = true;
} //<>//

void draw() {
  if (!running) return; // so it draws nothing until an image is selected
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
