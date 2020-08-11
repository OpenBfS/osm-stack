@building-fill: #e1e1e1;			// #cfcfcf; //Lch(84, 5, 70)
@building-line: darken(@building-fill, 15%);
@building-low-zoom: darken(@building-fill, 4%);

@building-major-fill: darken(@building-fill, 20%);
@building-major-line: darken(@building-major-fill, 25%);

@building-aeroway-fill: @building-major-fill;
@building-aeroway-line: darken(@building-aeroway-fill,15%);


#buildings {
  [zoom >= 13] {
    polygon-fill: @building-low-zoom;
    polygon-clip: false;
    [zoom >= 16] {
      line-color: @building-line;
      polygon-fill: @building-fill;
      line-width: .5;
      line-clip: false;
    }
  }
}

#buildings-major {
  [zoom >= 13] {
    [aeroway = 'terminal'] {
      polygon-fill: @building-aeroway-fill;
      polygon-clip: false;
      [zoom >= 15] {
        line-width: .75;
        line-clip: false;
        line-color: @building-aeroway-line;
      }
    }
    [amenity = 'place_of_worship'],
    [building = 'train_station'] {
      polygon-fill: lighten(@building-major-fill,10%);
      polygon-clip: false;
      [zoom >= 15] {
        line-width: .75;
        line-clip: false;
        line-color: @building-major-line;
      }
    }
  }
}

#bridge {
  [zoom >= 12] {
    polygon-fill: #b8b8b8;
  }
}
