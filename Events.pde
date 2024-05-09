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
  // Smooths the image with space
  if (key == ' ') {
    resultImg = smoothImage(resultImg, 0, 0, resultImg.width, resultImg.height);
    paintByNumberImg = pbnImage(resultImg);
  } else if (key == 'm' || key == 'M'){
    magnify = !magnify;
  } else if (key == 's' || key == 'S'){
    saveImages();
    println("saved");
  } else if (key == 'r' || key == 'R'){
    resultImg = colourImage(img);
    paintByNumberImg = pbnImage(resultImg);
  } else if (key == 'l' || key == 'L'){
    labelling = !labelling;
    // Don't recalculate resultImg as that will ignore smoothing
    paintByNumberImg = pbnImage(resultImg);
  } else if (key == 'b' || key == 'B'){
    blackAndWhiteMode = !blackAndWhiteMode;
    // Don't recalculate resultImg as that will ignore smoothing
    paintByNumberImg = pbnImage(resultImg);
  } else if (key == 'n' || key == 'N'){
    initialiseImages(); // Restart
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
