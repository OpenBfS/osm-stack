@station-color: #838383;
@station-text: darken(saturate(@station-color, 15%), 10%);

#stations {
  [railway = 'subway_entrance'][zoom >= 18] {
    marker-file: url('symbols/entrance.10.svg');
    marker-placement: interior;
    marker-fill: @transportation-icon;
    marker-clip: false;
    [zoom >= 19] {
      text-name: [ref];
      text-face-name: @book-fonts;
      text-size: 10;
      text-fill: @transportation-icon;
      text-dy: 10;
      text-halo-radius: @standard-halo-radius * 1.5;
      text-halo-fill: @standard-halo-fill;
      text-wrap-width: 0;
      text-placement: interior;
    }
  }

  [railway = 'station'][zoom >= 14] {
    marker-file: url('symbols/square.svg');
    marker-placement: interior;
    marker-fill: @station-color;
    marker-width: 4;
    marker-clip: false;
    [zoom >= 13] {
      marker-width: 6;
    }
    [zoom >= 15] {
      text-name: "[name]";
      text-face-name: @bold-fonts;
      text-size: 10;
      text-fill: @station-text;
      text-dy: 10;
      text-halo-radius: @standard-halo-radius * 1.5;
      text-halo-fill: @standard-halo-fill;
      text-wrap-width: 0;
      text-placement: interior;
    }
  }

  [railway = 'halt'] {
    [zoom >= 15] {
      marker-file: url('symbols/square.svg');
      marker-placement: interior;
      marker-fill: @station-color;
      marker-width: 4;
      marker-clip: false;
      [zoom >= 15] {
        marker-width: 6;
      }
    }
    [zoom >= 16] {
      text-name: "[name]";
      text-face-name: @bold-fonts;
      text-size: 10;
      text-fill: @station-text;
      text-dy: 10;
      text-halo-radius: @standard-halo-radius * 1.5;
      text-halo-fill: @standard-halo-fill;
      text-wrap-width: 0;
      text-placement: interior;
    }
  }

  [aerialway = 'station']::aerialway {
    [zoom >= 13] {
      marker-file: url('symbols/square.svg');
      marker-placement: interior;
      marker-fill: @station-color;
      marker-width: 4;
      marker-clip: false;
    }
    [zoom >= 15] {
      marker-width: 6;
    }
    [zoom >= 14] {
      text-name: "[name]";
      text-face-name: @book-fonts;
      text-size: 10;
      text-fill: @station-text;
      text-dy: 10;
      text-halo-radius: @standard-halo-radius * 1.5;
      text-halo-fill: @standard-halo-fill;
      text-wrap-width: 0;
      text-placement: interior;
    }
  }

  [railway = 'tram_stop'] {
    [zoom >= 15] {
      marker-file: url('symbols/square.svg');
      marker-placement: interior;
      marker-fill: @station-color;
      marker-width: 3;
      marker-clip: false;
      [zoom >= 15] {
        marker-width: 4;
      }
    }
    [zoom >= 16] {
      text-name: "[name]";
      text-face-name: @book-fonts;
      text-size: 10;
      text-fill: @station-text;
      text-dy: 10;
      text-halo-radius: @standard-halo-radius * 1.5;
      text-halo-fill: @standard-halo-fill;
      text-wrap-width: 0;
      text-placement: interior;
    }
  }
}
