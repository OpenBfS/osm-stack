@contour:         #C1A2A2;
@contour_text:	  #996666;
@raster-opacity:  0.3;

/* hillshade */
#srtm {
  [zoom >= 10] {
    raster-opacity: @raster-opacity;
    raster-scaling:bilinear;
    raster-colorizer-default-mode:discrete;
  }
}

#srtm_small {
  [zoom <= 9]
  [zoom >= 7] {
    raster-opacity: @raster-opacity;
    raster-scaling:bilinear;
    raster-colorizer-default-mode:discrete;
  }
}

#srtm_tiny {
  [zoom <= 6]
  [zoom >= 1] {
    raster-opacity: @raster-opacity;
    raster-scaling:bilinear;
    raster-colorizer-default-mode:discrete;
  }
}

#contour_200 {
   [zoom <= 12]
   [zoom >= 10] {
      line-color:   @contour;
      line-width:   0.4;
   }
}

#contour_100 {
   [zoom >= 16] {
      line-color:   @contour;
      line-width:   1;
   }
   [zoom <= 15]
   [zoom >= 13] {
      line-color:   @contour;
      line-width:   0.7;
   }
   [zoom >= 13] {
      text-placement:     line;
      text-size:          8;
      text-fill:          @contour_text;
      text-halo-radius:   0.8;
      text-face-name:     "DejaVu Sans Bold";
      text-name:          "[height]";
   }
}

#contour_10 {
   [zoom >= 16] {
      line-color:   @contour;
      line-width:   0.4;
      line-opacity: 0.8;
   }
   [zoom <= 15]
   [zoom >= 14] {
      line-color:   @contour;
      line-width:   0.4;
      line-opacity: 0.8;
   }
}

