@junction-text-color:             @overlay-text-color;
@halo-color-for-minor-road: white;

#junctions {
  [highway = 'motorway_junction'] {
    [zoom >= 15] {
      ref/text-name: "[ref]";
      ref/text-size: 10;
      ref/text-fill: @junction-text-color;
      ref/text-min-distance: 2;
      ref/text-face-name: @oblique-fonts;
      ref/text-halo-radius: @standard-halo-radius * 1.5;
      [zoom >= 12] {
        name/text-name: "[name]";
        name/text-size: 9;
        name/text-fill: @junction-text-color;
        name/text-dy: -9;
        name/text-face-name: @oblique-fonts;
        name/text-halo-radius: @standard-halo-radius;
        name/text-wrap-character: ";";
        name/text-wrap-width: 2;
        name/text-min-distance: 2;
      }
      [zoom >= 15] {
        ref/text-size: 12;
        name/text-size: 11;
        name/text-dy: -10;
      }
    }
  }

  [junction = 'yes'],
  [highway = 'traffic_signals'] {
    [zoom >= 15] {
      text-name: "[name]";
      text-size: 10;
      text-fill: black;
      text-face-name: @book-fonts;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @overlay-halo-color;
      text-wrap-width: 30;
      text-min-distance: 2;
      [zoom >= 17] {
        text-size: 11;
        /* Offset name on traffic_signals on zoomlevels where they are displayed
        in order not to hide the text */
        [highway = 'traffic_signals'] {
          text-dy: 14;
        }
      }
    }
  }
}

#bridge-text  {
  [man_made = 'bridge'] {
    [zoom >= 12][way_pixels > 62.5] {
      text-name: "[name]";
      text-size: 8;
      text-fill: black;
      text-face-name: @book-fonts;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @overlay-halo-color;
      text-min-distance: 2;
      text-wrap-width: 30;
      text-placement: interior;
      [way_pixels > 250] {
        text-size: 9;
      }
      [way_pixels > 1000] {
        text-size: 11;
        text-halo-radius: @standard-halo-radius * 1.5;
      }
      [way_pixels > 4000] {
        text-size: 12;
      }
      [way_pixels > 16000] {
        text-size: 13;
        text-halo-radius: 2;
      }
    }
  }
}

#roads-text-name {
  [highway = 'motorway'],
  [highway = 'trunk'],
  [highway = 'primary'] {
    [zoom >= 13] {
      text-name: "[name]";
      text-size: 8;
      text-fill: @overlay-text-color;
      text-spacing: 300;
      text-clip: false;
      text-placement: line;
      text-face-name: @book-fonts;
      [tunnel = 'no'] {
        text-halo-radius: @standard-halo-radius;
        [highway = 'motorway'] { text-halo-fill: @overlay-halo-color; }
        [highway = 'trunk'] { text-halo-fill: @overlay-halo-color; }
        [highway = 'primary'] { text-halo-fill: @overlay-halo-color; }
      }
    }
    [zoom >= 14] {
      text-size: 9;
    }
    [zoom >= 15] {
      text-size: 10;
    }
    [zoom >= 17] {
      text-size: 11;
    }
    [zoom >= 19] {
      text-size: 12;
    }
  }
  [highway = 'secondary'] {
    [zoom >= 13] {
      text-name: "[name]";
      text-size: 8;
      text-fill: @overlay-text-color;
      text-spacing: 300;
      text-clip: false;
      text-placement: line;
      text-face-name: @book-fonts;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @overlay-halo-color;
    }
    [zoom >= 14] {
      text-size: 9;
    }
    [zoom >= 15] {
      text-size: 10;
    }
    [zoom >= 17] {
      text-size: 11;
    }
    [zoom >= 19] {
      text-size: 12;
    }
  }
  [highway = 'tertiary'],
  [highway = 'tertiary_link'] {
    [zoom >= 14] {
      text-name: "[name]";
      text-size: 9;
      text-fill: @overlay-text-color;
      text-spacing: 300;
      text-clip: false;
      text-placement: line;
      text-face-name: @book-fonts;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @overlay-halo-color;
    }
    [zoom >= 17] {
      text-size: 11;
    }
    [zoom >= 19] {
      text-size: 12;
    }
  }
  
  [highway = 'residential'],
  [highway = 'unclassified'],
  [highway = 'road'] {
    [zoom >= 15] {
      text-name: "[name]";
      text-size: 8;
      text-fill: @overlay-text-color;
      text-spacing: 300;
      text-clip: false;
      text-placement: line;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @overlay-halo-color;
      text-face-name: @book-fonts;
    }
    [zoom >= 16] {
      text-size: 9;
    }
    [zoom >= 17] {
      text-size: 11;
      text-spacing: 400;
    }
    [zoom >= 19] {
      text-size: 12;
      text-spacing: 400;
    }
  }

  [highway = 'raceway'],
  [highway = 'service'] {
    [zoom >= 16] {
      text-name: "[name]";
      text-size: 9;
      text-fill: @overlay-text-color;
      text-spacing: 300;
      text-clip: false;
      text-placement: line;
      text-halo-radius: @standard-halo-radius;
      [highway = 'raceway'] { text-halo-fill: @overlay-halo-color; }
      [highway = 'service'] { text-halo-fill: @overlay-halo-color; }
      text-face-name: @book-fonts;
    }
    [zoom >= 17] {
      text-size: 11;
    }
  }

  [highway = 'living_street'],
  [highway = 'pedestrian'] {
    [zoom >= 15] {
      text-name: "[name]";
      text-size: 8;
      text-fill: @overlay-text-color;
      text-spacing: 300;
      text-clip: false;
      text-placement: line;
      text-halo-radius: @standard-halo-radius;
      [highway = 'living_street'] { text-halo-fill: @overlay-halo-color; }
      [highway = 'pedestrian'] { text-halo-fill: @overlay-halo-color; }
      text-face-name: @book-fonts;
    }
    [zoom >= 16] {
      text-size: 9;
    }
    [zoom >= 17] {
      text-size: 11;
    }
    [zoom >= 19] {
      text-size: 12;
    }
  }
}

#roads-area-text-name {
  [way_pixels > 3000],
  [zoom >= 17] {
    [zoom >= 15] {
      text-name: "[name]";
      text-size: 8;
      text-face-name: @book-fonts;
      text-placement: interior;
      text-wrap-width: 30;
    }
    [zoom >= 16] {
      text-size: 9;
    }
    [zoom >= 17] {
      text-size: 11;
    }
  }
}

#paths-text-name {
  [highway = 'track'] {
    [zoom >= 15] {
      text-name: "[name]";
      text-fill: @overlay-text-color;
      text-size: 8;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @overlay-halo-color;
      text-spacing: 300;
      text-clip: false;
      text-placement: line;
      text-face-name: @book-fonts;
      text-vertical-alignment: middle;
      text-dy: 5;
    }
    [zoom >= 16] {
      text-size: 9;
      text-dy: 7;
    }
    [zoom >= 17] {
      text-size: 11;
      text-dy: 9;
    }
  }

  [highway = 'bridleway'],
  [highway = 'footway'],
  [highway = 'cycleway'],
  [highway = 'path'],
  [highway = 'steps'] {
    [zoom >= 16] {
      text-name: "[name]";
      text-fill: @overlay-text-color;
      text-size: 9;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @overlay-halo-color;
      text-spacing: 300;
      text-clip: false;
      text-placement: line;
      text-face-name: @book-fonts;
      text-vertical-alignment: middle;
      text-dy: 7;
    }
    [zoom >= 17] {
      text-size: 11;
      text-dy: 9;
    }
  }
}
