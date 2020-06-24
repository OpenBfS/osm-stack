@water-text: #8e8e8e;
@glacier: #e7e7e7;
@glacier-line: #9cf;

@water-font-size: 10;
@water-font-size-big: 12;
@water-font-size-bigger: 15;
@water-wrap-width-size: 25;
@water-wrap-width-size-big: 35;
@water-wrap-width-size-bigger: 45;

#icesheet-poly-from-database {
  [natural = 'glacier']::natural {
    [zoom >= 6] {
      line-width: 0.75;
      line-color: @glacier-line;
      polygon-fill: @glacier;
      [zoom >= 8] {
        line-width: 1.0;
      }
      [zoom >= 10] {
        line-dasharray: 4,2;
        line-width: 1.5;
      }
    }
  }
}

#water-areas {
  [waterway = 'dock'],
  [waterway = 'canal'] {
    [zoom >= 9]::waterway {
      polygon-fill: @water-color;
      [way_pixels >= 4] {
        polygon-gamma: 0.75;
      }
      [way_pixels >= 64] {
        polygon-gamma: 0.6;
      }
    }
  }

  [landuse = 'basin'][zoom >= 7]::landuse {
    polygon-fill: @water-color;
    [way_pixels >= 4] {
      polygon-gamma: 0.75;
    }
    [way_pixels >= 64] {
      polygon-gamma: 0.6;
    }
  }

  [natural = 'water']::natural,
  [landuse = 'reservoir']::landuse,
  [waterway = 'riverbank']::waterway {
    [zoom >= 6] {
      polygon-fill: @water-color;
      [way_pixels >= 4] {
        polygon-gamma: 0.75;
      }
      [way_pixels >= 64] {
        polygon-gamma: 0.6;
      }
    }
  }
}

#water-lines-low-zoom {
  [waterway = 'river'][zoom >= 8][zoom < 12] {
    [intermittent = 'yes'] {
      line-dasharray: 8,4;
      line-cap: butt;
      line-join: round;
      line-clip: false;
    }
    line-color: @water-color;
    line-width: 0.7;
    [zoom >= 9] { line-width: 1.2; }
    [zoom >= 10] { line-width: 1.6; }
  }
}

#water-lines {
  [waterway = 'canal'][zoom >= 12],
  [waterway = 'river'][zoom >= 12],
  [waterway = 'wadi'][zoom >= 13] {
    [bridge = 'yes'] {
      [zoom >= 14] {
        bridgecasing/line-color: black;
        bridgecasing/line-join: round;
        bridgecasing/line-width: 6;
        [zoom >= 15] { bridgecasing/line-width: 7; }
        [zoom >= 17] { bridgecasing/line-width: 11; }
        [zoom >= 18] { bridgecasing/line-width: 13; }
      }
    }
    [intermittent = 'yes'],
    [waterway = 'wadi'] {
      [bridge = 'yes'][zoom >= 14] {
        bridgefill/line-color: white;
        bridgefill/line-join: round;
        bridgefill/line-width: 4;
        [zoom >= 15] { bridgefill/line-width: 5; }
        [zoom >= 17] { bridgefill/line-width: 9; }
        [zoom >= 18] { bridgefill/line-width: 11; }
      }
      line-dasharray: 4,3;
      line-cap: butt;
      line-join: round;
      line-clip: false;
    }
    line-color: @water-color;
    line-width: 2;
    [zoom >= 13] { line-width: 3; }
    [zoom >= 14] { line-width: 5; }
    [zoom >= 15] { line-width: 6; }
    [zoom >= 17] { line-width: 10; }
    [zoom >= 18] { line-width: 12; }
    line-cap: round;
    line-join: round;
    [int_tunnel = 'yes'] {
      line-dasharray: 4,2;
      line-cap: butt;
      line-join: miter;
      a/line-color: #f5f5f5;
      a/line-width: 1;
      [zoom >= 14] { a/line-width: 2; }
      [zoom >= 15] { a/line-width: 3; }
      [zoom >= 17] { a/line-width: 7; }
      [zoom >= 18] { a/line-width: 8; }
    }
  }

  [waterway = 'stream'],
  [waterway = 'ditch'],
  [waterway = 'drain'] {
    [zoom >= 14] {
      [bridge = 'yes'] {
        [zoom >= 14] {
          bridgecasing/line-color: black;
          bridgecasing/line-join: round;
          bridgecasing/line-width: 4;
          [waterway = 'stream'][zoom >= 15] { bridgecasing/line-width: 4; }
          bridgeglow/line-color: white;
          bridgeglow/line-join: round;
          bridgeglow/line-width: 3;
          [waterway = 'stream'][zoom >= 15] { bridgeglow/line-width: 3; }
        }
      }
      [intermittent = 'yes'] {
        line-dasharray: 4,3;
        line-cap: butt;
        line-join: round;
        line-clip: false;
      }
      line-width: 1.5;
      line-color: @water-color;
      [waterway = 'stream'][zoom >= 15] {
        line-width: 3;
      }
      [int_tunnel = 'yes'][zoom >= 15] {
        line-width: 3.5;
        [waterway = 'stream'] { line-width: 4.5; }
        line-dasharray: 4,2;
        a/line-width: 1;
        [waterway = 'stream'] { a/line-width: 2; }
        a/line-color: #f5f5f5;
      }
    }
  }

  [waterway = 'derelict_canal'][zoom >= 12] {
    line-width: 1.5;
    line-color: #d3d3d3;
    line-dasharray: 4,4;
    line-opacity: 0.5;
    line-join: round;
    line-cap: round;
    [zoom >= 13] {
      line-width: 2.5;
      line-dasharray: 4,6;
    }
    [zoom >= 14] {
      line-width: 4.5;
      line-dasharray: 4,8;
    }
  }
}

#water-lines-text {
  [lock != 'yes'][int_tunnel != 'yes'] {
    [waterway = 'river'][zoom >= 13] {
      text-name: "[name]";
      text-face-name: @oblique-fonts;
      text-placement: line;
      text-fill: @water-text;
      text-spacing: 400;
      text-size: 10;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @standard-halo-fill;
      [zoom >= 14] { text-size: 12; }
      [int_tunnel = 'yes'] { text-min-distance: 200; }
    }

    [waterway = 'canal'][zoom >= 13][zoom < 14] {
      text-name: "[name]";
      text-face-name: @oblique-fonts;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @standard-halo-fill;
      text-size: 10;
      text-placement: line;
      text-fill: @water-text;
    }

    [waterway = 'stream'][zoom >= 15] {
      text-name: "[name]";
      text-size: 10;
      text-face-name: @oblique-fonts;
      text-fill: @water-text;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @standard-halo-fill;
      text-spacing: 600;
      text-placement: line;
      text-vertical-alignment: middle;
      text-dy: 8;
    }

    [waterway = 'drain'],
    [waterway = 'ditch'] {
      [zoom >= 15] {
        text-name: "[name]";
        text-face-name: @oblique-fonts;
        text-size: 10;
        text-fill: @water-text;
        text-spacing: 600;
        text-placement: line;
        text-halo-radius: @standard-halo-radius;
        text-halo-fill: @standard-halo-fill;
      }
    }

    [waterway = 'canal'][zoom >= 14] {
      text-name: "[name]";
      text-size: 10;
      text-fill: @water-text;
      text-placement: line;
      text-face-name: @oblique-fonts;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @standard-halo-fill;
    }

    [waterway = 'derelict_canal'][zoom >= 13] {
      text-name: "[name]";
      text-size: 10;
      text-fill: #b4b4b4;
      text-face-name: @oblique-fonts;
      text-placement: line;
      text-spacing: 600;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @standard-halo-fill;
      [zoom >= 14] {
        text-size: 12;
      }
    }
  }
}

#text-poly[zoom >= 10], #text-point[zoom >= 10] {
  [feature = 'natural_water'],
  [feature = 'landuse_reservoir'],
  [feature = 'landuse_basin'] {
    [zoom >= 10][way_pixels > 3000],
    [zoom >= 17] {
      text-name: "[name]";
      text-size: @water-font-size;
      text-wrap-width: @water-wrap-width-size;
      [way_pixels > 12000] {
        text-size: @water-font-size-big;
        text-wrap-width: @water-wrap-width-size-big;
      }
      [way_pixels > 48000] {
        text-size: @water-font-size-bigger;
        text-wrap-width: @water-wrap-width-size-bigger;
      }
      text-fill: @water-text;
      text-face-name: @oblique-fonts;
      text-halo-radius: @standard-halo-radius;
      text-halo-fill: @standard-halo-fill;
      text-placement: interior;
    }
  }
}
