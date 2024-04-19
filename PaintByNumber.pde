// Images
PImage img;
PImage resultImg;
PImage paintByNumberImg;
PImage paletteImg;

// Image resize dimensions
int imgResizeWidth = 600; // only width, as height has to be scaled proportionally
int paletteImgResizeWidth = 500;
int paletteImgResizeHeight = 500;

// Palette draw settings
int paletteRectWidth = 50;
int paletteRectSpacing = 50;
int paletteRectRadius = 10;

ArrayList<Integer> palette; // requires Integer class, as color is a primitive

void settings() {
  //img = loadImage("Images/colour wheel.png");
  //img = loadImage("Images/hill.jpg");
  //img = loadImage("Images/big hill.jpg");
  //img = loadImage("Images/face.jpg");
  img = loadImage("Images/mayflower.jpg");
  img.resize(imgResizeWidth, 0);
  resultImg = img.copy();
  paintByNumberImg = createImage(img.width, img.height, RGB);
  //paletteImg = loadImage("Images/colour wheel.png");
  //paletteImg = loadImage("Images/palette.jpg");
  //paletteImg = loadImage("Images/face.jpg");
  paletteImg = loadImage("Images/PBNifyTestPalette.png");
  //paletteImg = loadImage("Images/mayflower.jpg");
  paletteImg.resize(paletteImgResizeWidth, paletteImgResizeHeight);
  size(img.width + resultImg.width + paintByNumberImg.width, img.height + paletteImg.height);
}

void setup() {
  // Startup location
  surface.setLocation(100, 100);
  palette = new ArrayList<Integer> ();
  resultImg = colourImage(img);
  paintByNumberImg = pbnImage(resultImg);
}


void mouseClicked() {
  // Add paints with left click
  if (mouseButton == LEFT && mouseX < paletteImg.width && mouseY > img.height) {
    int x = mouseX;
    int y = mouseY - img.height;
    paletteImg.loadPixels();
    int index = y * paletteImg.width + x;
    color colourToAdd = paletteImg.pixels[index];
    if (!palette.contains(Integer.valueOf(colourToAdd))) {
      palette.add(colourToAdd);
    }
    paletteImg.updatePixels();
  }
  // Remove paints with right click
  // If the mouse is on the palette area or on the result image
  if (mouseButton == RIGHT && (mouseX > paletteImg.width && mouseY > img.height 
  || mouseX > img.width && mouseX < img.width + resultImg.width && mouseY < resultImg.height)) { 
    loadPixels();
    int index = mouseY * width + mouseX;
    color colorToRemove = pixels[index];
    palette.remove(Integer.valueOf(colorToRemove)); // Does nothing if colour is not in the palette
    updatePixels();
  }
  resultImg = colourImage(img);
  paintByNumberImg = pbnImage(resultImg);
}

void keyPressed() {
  // smooths the image with space
  if (key == ' ') {
    resultImg = smoothImage(resultImg);
    paintByNumberImg = pbnImage(resultImg);
  } else if (key == 'm'){
    magnify = !magnify;
  } else if (key == CODED) {
    if (keyCode == UP) {
      blurKernelSize += 2;
    }
    if (keyCode == DOWN) {
      blurKernelSize -= 2;
    }
    if (blurKernelSize < 3) blurKernelSize = 3;
    if (blurKernelSize >= min(resultImg.width, resultImg.height)) blurKernelSize = min(resultImg.width, resultImg.height);
    println("BlurKernelSize: ", blurKernelSize);
  }
  
}

void draw() {
  background(0);
  //image(blurImage(img), 0, 0);
  image(img, 0, 0);
  image(resultImg, img.width, 0);
  image(paintByNumberImg, img.width + resultImg.width, 0);
  image(paletteImg, 0, img.height);
  drawPalette();
  surface.setTitle("Paint By Number - " + "Blur Kernel Size: " + blurKernelSize + " - Frame Rate: " + round(frameRate));
  if (magnify) {
    magnify();
  }
  
}

void drawPalette() {
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
    if (x + rectWidth > width) {
      row++;
      column = 0;
      // Recalculate for new row
      x = paletteImg.width + spacing * (column + 1) + rectWidth * column;
    }
    int y = img.height + spacing * (row + 1) + rectWidth * row;
    rect(x, y, rectWidth, rectWidth);
    
    // Draw the number of the paint
    textAlign(CENTER, CENTER);
    fill((brightness(paint) > 240) ? 0 : 255); // Set text color to black if paint is light, white if paint is dark. 240 is threshold found by trial and error
    textSize(rectWidth / 2); // Adjust text size to fit inside the rectangle
    text(i, x + rectWidth / 2, y + rectWidth / 2); // Draw index in the middle
    
    column++;
  }
}
