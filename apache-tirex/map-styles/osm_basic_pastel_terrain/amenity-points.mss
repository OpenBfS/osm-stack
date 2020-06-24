@marina-text: #717171; // also swimming_pool
@wetland-text: darken(#939393, 25%); /* Also for marsh and mud */
@shop-icon: #676767;
@shop-text: #939;
@transportation-icon: #6e6e6e;
@transportation-text: #575757;
@airtransport: #888; // #757575;
@health-color: #505050;
@amenity-brown: #4d4d4d;
@man-made-icon: #555;
@landform-color: #9b9b9b;

@landcover-font-size: 10;
@landcover-font-size-big: 12;
@landcover-font-size-bigger: 15;
@landcover-wrap-width-size: 25;
@landcover-wrap-width-size-big: 35;
@landcover-wrap-width-size-bigger: 45;
@landcover-face-name: @oblique-fonts;

@standard-wrap-width: 5;
@standard-text-size: 14;
@standard-font: @book-fonts;



#amenity-points, #amenity-points-poly {
  [feature = 'aeroway_aerodrome'][zoom >= 11][zoom < 15] {
    marker-file: url('symbols/aerodrome.12.svg');
    marker-placement: interior;
    marker-clip: false;
    marker-fill: @airtransport;
  }
}

#text-poly, #text-point {
	[feature = 'leisure_park'],
	[feature = 'leisure_recreation_ground'],
	[feature = 'landuse_recreation_ground'],
	[feature = 'landuse_village_green'],
	[feature = 'leisure_common'],
	[feature = 'leisure_garden'] {
		[zoom >= 10][way_pixels > 3000] {
			text-name: "[name]";
			text-size: @landcover-font-size;
			text-fill: darken(@park, 60%);
			text-face-name: @landcover-face-name;
			text-halo-radius: @standard-halo-radius;
			text-halo-fill: @standard-halo-fill;
			text-placement: interior;
			text-wrap-width: @standard-wrap-width;
			[way_pixels > 12000] {
			  text-size: @landcover-font-size-big;
			  text-wrap-width: @landcover-wrap-width-size-big;
			}
			[way_pixels > 48000] {
			  text-size: @landcover-font-size-bigger;
			  text-wrap-width: @landcover-wrap-width-size-bigger;
			}
		}
	}

	[feature = 'boundary_national_park'],
	[feature = 'natural_wood'],
	[feature = 'landuse_forest'],
	[feature = 'leisure_nature_reserve'] {
		[zoom >= 8][way_pixels > 3000][is_building = 'no'],
		[zoom >= 17] {  
			text-name: "[name]";
			text-size: @landcover-font-size;
			text-wrap-width: @landcover-wrap-width-size;
			[way_pixels > 12000] {
				text-size: @landcover-font-size-big;
				text-wrap-width: @landcover-wrap-width-size-big;
			}
			[way_pixels > 48000] {
				text-size: @landcover-font-size-bigger;
				text-wrap-width: @landcover-wrap-width-size-bigger;
			}
			text-face-name: @landcover-face-name;
			text-halo-radius: @standard-halo-radius;
			text-halo-fill: @standard-halo-fill;
			text-placement: interior;
			[feature = 'natural_wood'],
			[feature = 'landuse_forest'] {
				text-fill: @forest-text;
			}
			[feature = 'boundary_national_park'],
			[feature = 'leisure_nature_reserve'] {
				text-fill: darken(@park, 70%);
			}
		}
	}


  [feature = 'aeroway_aerodrome'][zoom >= 11][zoom < 15] {
    text-name: "[name]";
    text-size: @standard-text-size;
    text-fill: darken(@airtransport, 15%);
    text-dy: -13;
    text-face-name: @oblique-fonts;
    text-halo-radius: @standard-halo-radius;
    text-halo-fill: @standard-halo-fill;
    text-placement: interior;
    text-wrap-width: @standard-wrap-width;
  }
  
  [feature = 'amenity_hospital'][zoom >= 16] {
    text-name: "[name]";
    text-fill: @health-color;
	 text-size: @landcover-font-size;
	 text-face-name: @landcover-face-name;
    text-halo-radius: @standard-halo-radius;
    text-halo-fill: @standard-halo-fill;
    text-wrap-width: @standard-wrap-width;
    text-placement: interior;
  }
      
	[feature = 'amenity_school'],
	[feature = 'amenity_college'],
	[feature = 'amenity_university'] {
		[zoom >= 16] {
			text-name: "[name]";
			text-size: @landcover-font-size;
			text-face-name: @landcover-face-name;
			text-halo-radius: @standard-halo-radius;
			text-halo-fill: @standard-halo-fill;
			text-wrap-width: @standard-wrap-width;
			text-placement: interior;
			text-fill: darken(@societal_amenities, 70%);
		}
	}

	[feature = 'landuse_cemetery'],
	[feature = 'amenity_grave_yard'] {

		[zoom >= 10][way_pixels > 3000][is_building = 'no'],
		[zoom >= 17][is_building = 'no'] {
			text-name: "[name]";
			text-size: @landcover-font-size;
			text-wrap-width: @landcover-wrap-width-size;
			[way_pixels > 12000] {
				text-size: @landcover-font-size-big;
				text-wrap-width: @landcover-wrap-width-size-big;
			}
			[way_pixels > 48000] {
				text-size: @landcover-font-size-bigger;
				text-wrap-width: @landcover-wrap-width-size-bigger;
			}
			text-face-name: @landcover-face-name;
			text-halo-radius: @standard-halo-radius;
			text-halo-fill: @standard-halo-fill;
			text-placement: interior;
			text-fill: darken(@cemetery, 50%);
			text-halo-radius: @standard-halo-radius * 1.5; /* extra halo needed to overpower the cemetery polygon pattern */
		}
	}
}



