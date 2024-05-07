# Paint By Number Generator

## Notes
* Uses an image and a palette image from the Images folder - change which images to use by editing the imgFile and paletteImgFile variables.  
* The larger the image, the longer processing will take. Turn off labelling until you want it, as calculating label positions every time is expensive.  
* The percentage under each palette square shows the percentage of the image that is made up by that paint, rounded to 1dp.  
* Label locations calculated using the [Pole Of Inaccessibility](https://en.wikipedia.org/wiki/Pole_of_inaccessibility) of each region, from modifying the algorithm created by the Mapbox team ([Explanation Blog](https://blog.mapbox.com/a-new-algorithm-for-finding-a-visual-center-of-a-polygon-7c77e6492fbc), [GitHub Repo](https://github.com/mapbox/polylabel))
* Colour distance used in finding the closest palette colour to paint a pixel is calculated using the redmean formula ![Redmean](https://wikimedia.org/api/rest_v1/media/math/render/svg/95ee06baaa28944c5b1e06876439d1b579cf03c9)  
to more accurately calculate the [colour difference](https://en.wikipedia.org/wiki/Color_difference) in sRGB space for the human eye than using the Euclidean distance  
![Euclidean distance](https://wikimedia.org/api/rest_v1/media/math/render/svg/15763fc04b6dbbc90c64db3b39a1442106a394af)  

## Mouse Controls:  
**Left click** on the palette image to add that colour to the palette  
**Right click** on a colour in the palette image, palette, or filled image to remove that colour from the palette  
**Drag with left click** to select a rectangular area and blur the selected area on release
  
## Keyboard Controls:  
**Space** to smooth the filled image  
**L** to toggle labelling  
**S** to save current pbn image, filled image, and palette  
**M** to magnify  
**R** to revert smoothing changes  
**B** to toggle black and white mode  
**Up Arrow** to increase the blur strength (blur kernel size) for smoothing  
**Down Arrow** to decrease the blur strength (blur kernel size) for smoothing  

## Examples:
![Filled Image](/Saves/2024.05.07_18.52.29/filledImg.jpg)  
![Paint By Number Image](/Saves/2024.05.07_18.52.29/paintByNumberImg.jpg)  
![Palette](/Saves/2024.05.07_18.52.29/palette.jpg)  
