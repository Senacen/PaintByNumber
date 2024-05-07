void saveImages() {
   println("saving");
   String folderName = "saves/" + getTimeStamp();
   createFolder(folderName);
   loadPixels();
   PImage saveFilledImg = get(img.width, 0, resultImg.width, resultImg.height);
   PImage savePaintByNumberImg = get(img.width + resultImg.width, 0, paintByNumberImg.width, paintByNumberImg.height);
   PImage savePalette = get(paletteImg.width, img.height, width - paletteImg.width, height - img.height);
   saveFilledImg.save(folderName + "/filledImg.jpg");
   savePaintByNumberImg.save(folderName + "/paintByNumberImg.jpg");
   savePalette.save(folderName + "/palette.jpg");
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
