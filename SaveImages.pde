void saveImages() {
   println("saving");
   String folderName = "Saves/" + getTimeStamp();
   createFolder(folderName);
   loadPixels();
   PImage saveFilledImg = get(img.width, 0, resultImg.width, resultImg.height);
   PImage savePaintByNumberImg = get(img.width + resultImg.width, 0, paintByNumberImg.width, paintByNumberImg.height);
   
   // Calculating palette save bounds
   int x = paletteLeftX - paletteRectSpacing;
   int y = paletteTopY - paletteRectSpacing;
   int savePaletteWidth = min(width, paletteRightX + paletteRectSpacing) - x; // Make sure in the window
   int savePaletteHeight = min(height, paletteBottomY + paletteRectSpacing) - y;
   PImage savePalette = get(x, y, savePaletteWidth, savePaletteHeight);
   saveFilledImg.save(folderName + "/filledImg.png");
   savePaintByNumberImg.save(folderName + "/paintByNumberImg.png");
   savePalette.save(folderName + "/palette.png");
}

void createFolder(String folderName) {
  // Create a new folder in the sketch's data directory
  File folder = new File(sketchPath(folderName));
  if (!folder.exists()) {
    folder.mkdir();
  }
}

String getTimeStamp() {
  // Get the current time as a formatted string
  Calendar cal = Calendar.getInstance();
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd_HH.mm.ss"); // Cannot include colons by windows
  return sdf.format(cal.getTime());
}

void saveCopyToImagesFolder(String path) {
  // Create a File object for the image to copy
  File imageToCopy = new File(path);
  
  // Extract the file name from the path
  String fileName = imageToCopy.getName();
  
  // Create a File object for the destination in the "Images" folder
  File destinationFile = new File(sketchPath("Images") + "/" + fileName);
  
  if (!destinationFile.exists()) {
    try {
      // Copy the file to the "Images" folder
      Files.copy(imageToCopy.toPath(), destinationFile.toPath());
      println("Image copied to Images folder: " + destinationFile.getAbsolutePath());
    } catch (Exception e) {
      println("Failed to copy the image to Images folder: " + e.getMessage());
    }
  }
  
}
