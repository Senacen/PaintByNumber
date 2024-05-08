class ColourCountComparator implements Comparator<Integer[]> {
    public int compare(Integer[] c1, Integer[] c2) {
        return -1 * Integer.compare(c1[1], c2[1]); // Times -1 to sort in reverse order, sorting on the counts which is [1]
    }
}
// Sort the palette and paint count by paint count ascending
void sortPalette() {
  paletteWithCounts = new ArrayList<Integer[]>();
  for (int i = 0; i < palette.size(); i++) {
    Integer[] colourWithCount = new Integer[2];
    colourWithCount[0] = palette.get(i);
    colourWithCount[1] = paintCounts.get(i);
    paletteWithCounts.add(colourWithCount);
  }
  Collections.sort(paletteWithCounts, new ColourCountComparator());
  for (int i = 0; i < paletteWithCounts.size(); i++) {
    Integer[] colourWithCount = paletteWithCounts.get(i);
    palette.set(i, colourWithCount[0]);
    paintCounts.set(i, colourWithCount[1]);
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
