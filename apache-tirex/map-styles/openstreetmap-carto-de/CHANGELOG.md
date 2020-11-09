# Note: This is the upstream changelog not the one from openstreetmap-carto-de
openstreetmap-carto-de does not maintain a changelog. Instead have a look at the
git history. openstreetmap-carto-de commit messages are usually prefixed by "GERMAN STYLE:"

## [Unreleased](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.19.0...master)

## [v4.19.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.18.0...v4.19.0) - 2019-01-18
## Changes
- Adding rendering for boundary=protected_area (#3509)
- Nature reserve boundaries revision (#3574) 
- Adding support of amenity=vending_machine (#3601)
- Adding more barrier icons (#3602)
- Changing allotments color and adding outline (#3625)
- Reducing priority of tourism=attraction and rendering from z17 (#3603)
- Changing tourism outline color (#3582)
- Making country borders thicker at z8 and z9 (#3563)
- Rendering parking from z14 (#3612)
- Starting to render most patterns at z13 instead of z14 (#3610) 
- Changing zoom level and text size for place=hamlet (#3626)
- Rendering airport gate refs black instead of purple (#3620)
- Updating zoom levels by height for masts, towers and telescopes (#3536)
- Hiding underground parking (#3600)
- Rendering ref of minor roads more than once (#3627)
- Adjusting width of highway=construction (#3580)
- Selecting only motorway_link to tertiary_link as link (#3567)
- Reducing tertiary-link width (#3570)
- Changing certain amenity icons to grey (#3586)
- Converting springs to use ST_PointOnSurface and reformatting SQL (#3233)
- Adding "religious-icon" as color variable for #000000 (#3642)
- Adding "barrier-icon" color variable in #3f3f3f for barriers (#3643)
- Fixing inconsistency of leisure=ice_rink (#3598)
- Fixing label opacity for tourism features (#3616)
- Reverting lowzoom nobuilding test change (#3622)
- Removing trailing whitespace (#3637)

## [v4.18.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.17.0...v4.18.0) - 2018-12-21
## Changes
- Adding rendering for healthcare tag scheme
  - Changing hospital icon
  - Changing healthcare color to red
- Changing natural=scrub color
- Changing landuse=allotments color and pattern
- Adding rendering for natural=cape
- Rendering leisure=ice_rink
- Adding rendering for man_made=crane
- Adding icons for shop=fabric and shop=carpet
- Updating icons for amenity=arts_centre, leisure=slipway, amenity=restaurant/amenity=food_court and man_made=storage_tank/man_made=silo
- Using dedicated icon for artwork_type=bust
- Rendering railway pattern on z12
- Showing labels of big states (like Alaska)
- Moving railway=tram_stop and station=subway later
- Adding rendering for more private POIs
- Removing smoothing in leisure=track and attraction=water_slide
- Using subway bridge style for subway construction bridges
- Rendering wind turbines names and other tweaks
- Changing man_made gray and text color, making text-dy uniform
- Small documentation and code fixes
>>>>>>> v4.19.0

## [v4.17.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.16.0...v4.17.0) - 2018-11-23
## Changes
- Showing natural areas from z5
- Cleaning up medium zoom rendering, including:
  - Making societal amenities look like residential on z10-z12
  - Rendering motorway junction names from z13 instead of z12
  - Dropping buildings up to z13 instead of z12
  - Correctly dropping minor waterways from z13
  - Rendering intermittent streams/ditches/drains from z15
  - Reducing lightening of tramways
- Rendering religious landuse and place of worship lighter
- Adding text-repeat-distance for highway names
- Rendering dots for gastronomy objects on z17
- Changing icon for tourism=artwork
- Adding icons for memorial subtags
- Rendering man_made=telescope
- Rendering amenity=internet_cafe
- Adding icon for amenity=public_bookcase
- Adding icons for barrier=cattle_grid and barrier=stile
- Adding icon for leisure=fishing
- Rendering entrance for underground parking
- Rendering basin=detention/infiltration as intermittent water
- Tweaking outline of swimming pools and rendering it from z17
- Moving danger_area into landuse-overlay
- Buildings code rewrite

## [v4.16.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.15.0...v4.16.0) - 2018-10-19
## Changes
- Changing societal amenities color to less intensive
- Adding rendering for natural=strait
- Adding rendering for leisure=track on lines
- Adding icon for amenity=vehicle_inspection
- Adding icon for leisure=sports_centre + sport=swimming and leisure=swimming_area
- Adding icon for tourism=gallery
- Changing color for aeroway=apron in aerodromes
- Moving amenity=post_box to z19+
- Moving amenity=atm to z19+
- Replacing icon for information=tactile_model
- Ordering amenity_lines by layer
- Small documentation and code fixes

## [v4.15.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.14.0...v4.15.0) - 2018-09-21
## Changes
- Changing gastronomy objects color to orange (affects restaurant, fast_food, ice_cream, food_court, bar, cafe, nightclub, pub and biergarten)
- Changing farmland and societal amenities (like school, hospital etc.) colors to fit better into the overall color systematic
- Adding rendering for man_made=wastewater_plant and man_made=water_works
- Adding icon for man_made=storage_tank and man_made=silo
- Adding icon for amenity=bicycle_repair_station
- Adding icon for leisure=amusement_arcade
- Adding icon for shop=bookmaker
- Adding icon for shop=trade and shop=wholesale
- Adding rendering for attraction=water_slide
- Rendering most of the road links thinner (affects trunk_link, primary_link, secondary_link)
- Moving manors to z16+
- Fixing missing country labels on z4 (affects Canada, Russia and Greenland)
- Small code and icon fixes

## [v4.14.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.13.0...v4.14.0) - 2018-08-17
## Changes
- Added text-repeat-distance for waterways
- Added text-repeat-distance for railways
- Added icon for leisure=bowling_alley
- Added icon for leisure=outdoor_seating
- Added icon for leisure=bird_hide
- Added icon for shop=video
- Added icon for shop=paint
- Added icon for shop=massage
- Increased casing width of tertiary road on z12
- Standard text halo for fitness_centre and fitness_station
- Updated Docker images definitions
- Small documentation updates

## [v4.13.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.12.0...v4.13.0) - 2018-07-23
## Changes
- Increased shield distances on roads
- Added icon for shop=ticket
- Added icon for shop=houseware
- Added icon for shop=charity
- Added icon for shop=second_hand
- Added icon for shop=interior_decoration
- Added icon for amenity=bureau_de_change
- Added icon for amenity=casino
- Added icon for amenity=boat_rental
- Updated shop=department_store icon
- Small documentation and code fixes

## [v4.12.1](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.12.0...v4.12.1) - 2018-06-29
## Changes
- Stop rendering "surface" tag, which was causing breaking performance issues

## [v4.12.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.11.0...v4.12.0) - 2018-06-22
### Major changes
- Dropped subpixel accuracy for areas, which includes tuning some database indexes. When deployed, it might speed up reading data.

### Changes
- Added rendering “surface” tag on roads with a pattern
- More vertical objects rendering and tuning (man_made=tower types, man_made=chimney, man_made=communications_tower)
- tourism=information types rendering and tuning (information=audioguide, board, guidepost, map, office, tactile_map, tactile_model and terminal)
- Added rendering for place=quarter
- Added rendering of historic=city_gate
- Added rendering of lock_name
- Ditch and drain name labels are rendered with some offset
- Pixel aligned ford icon
- Made amenity=shelter icon brown
- Finer man_made=pier width rendering
- Rendering living street tunnels different from residential
- Added rendering of overground power=cable like power=line
- Small documentation and code fixes

## [v4.11.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.10.0...v4.11.0) - 2018-05-11
### Changes
- Fixed office/amenity conflict
- Brightened built-up areas on z12
- Refurbished natural=spring icon
- Added rendering for amenity=police and amenity=fire_station areas
- Added rendering of amenity=nursing_home
- Added rendering of amenity=childcare
- Added rendering of amenity=driving_school
- Added area rendering for amenity=bus_station
- Added area rendering of amenity=taxi
- Made highway=traffic_signals icon less obtrusive
- Moved barriers to higher zoom level
- Hiding railway=platform with location=underground, tunnels and covered=yes
- Small documentation and code fixes

## [v4.10.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.9.0...v4.10.0) - 2018-04-20
### Changes
- Adding rendering for historic=castle and historic=manor
- Adding rendering office=* as dots + names
- Adding rendering for waterway=waterfall
- Adding place=square name rendering for nodes
- Adding rendering for big natural=bay
- Adding rendering for leisure=beach_resort
- Adding rendering for amenity=parking_space
- Adding rendering of aerialway=zip_line
- Adding rendering for shop=bed
- Adding rendering for shop=video_games
- Adding halo to roads on z6 and z7
- Extending intermittent waterbody rendering to landuse=basin
- Moving highway=mini_roundabout rendering to higher zoom level
- Dropping waterway=derelict_canal rendering
- Small documentation and code fixes

## [v4.9.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.8.0...v4.9.0) - 2018-03-23
### Major changes
- A bug where closed ways with natural=cliff or natural=tree_row were not rendering has been fixed. This required fixing a transform bug. The fix will apply to all objects when they are created in OSM, but there is no migration for existing databases. Deployments will have to decide if the effects are serious enough to require them to reload the database.

### Changes
- Adding place=square name rendering
- Adding rendering for different types of towers and masts
- Making gardens to use grass color with plant nursery pattern
- Adding rendering for intermittent water bodies
- Give oceans outline and simplify shapefiles on z0-7
- Simplify (generalize) admin borders
- Move natural=grassland and landuse=meadow earlier
- Start rendering aerialway name
- Adding icons for amenity=bbq, amenity=shower, leisure=sauna and advertising=column
- Adding special icons for shop=dairy, shop=medical_supply and shop=music
- Move amenity=toilets to higher zoom levels
- Fixing some SVG icons artifacts
- Make military=danger_area font dark pink and slanted
- Changing rendering for construction=steps to distinguish it from roads
- Changing label colour of private parking
- Small documentation and code fixes

## [v4.8.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.7.0...v4.8.0) - 2018-02-23
### Changes
- Made military area rendering less prominent
- Adding rendering for historic=wayside_shrine
- Adding rendering for historic=fort
- Adding rendering for amenity=public_bath
- Adding rendering for shop=chocolate
- Adding rendering for barrier=toll_booth (nodes)
- Adding rendering barrier=log
- Adding rendering for amenity=waste_disposal
- Moving tourism-boundary under barrier layer
- Docker: run osm2pgsql in slim mode
- Fix operator precedence for hstore queries
- Small documentation fixes

## [v4.7.1](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.7.0...v4.7.1) - 2018-01-31
### Changes
- Fix rendering bug (#3043) with access=yes|permissive tags

## [v4.7.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.6.0...v4.7.0) - 2018-01-26
### Changes
- Adding icon for tourism=apartment
- Adding icon for leisure=firepit
- Yellow background for amenity=arts_centre
- Start rendering natural=heath earlier
- Start rendering entrances
- Changing tourism=picnic_site icon colour to green
- Move emergency=phone to higher zoom level
- Rendering seasonal waterways as intermittent
- Update Noto fonts to Phase III
- Fine-tuning of bridge labels
- Documentation changes and updates

## [v4.6.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.5.0...v4.6.0) - 2017-12-17
### Changes
- Change sports_centre and stadium color to light green
- Change shades of green for landuse/leisure=recreation_ground and garden
- Do not render glaciers and icesheets on z6 and z7
- Do not render very small water areas on low zoom
- Do not render small national parks and nature reserves
- Do not render ferries on z7
- Improve rendering for bus guideways
- For built-up areas, replace the external data on z8 and z9 by OSM data
- Do not render bicycle/motorbike parking icons to z17
- Render community_centre and social_facility areas in light yellow

## [v4.5.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.4.0...v4.5.0) - 2017-11-17
### Major changes
- Cleaning up low zoom levels (z5-z7):
  - Rendering roads from z6 instead of z5
  - Rendering national parks from z8 instead of z7
  - Rendering railways from z8 instead of z7
- Changing parking color from yellow to gray

### Changes
- Unified rendering of leisure=fitness_station and leisure=fitness_centre
- Rendering of military=bunker
- Rendering all station buildings as major buildings
- Text wrapping for station labels
- Changing windmill color from amenity brown to man_made gray
- Some other documentation and code changes

## [v4.4.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.3.0...v4.4.0) - 2017-10-20
### Major changes
- Rendering inland water areas and labels from z0
- Rendering island and islet labels earlier

### Changes
- Rendering of amenity=marketplace
- Rendering of landuse=religious
- Rendering shop=pastry like shop=confectionery
- Rendering of addr:unit
- Rendering natural=bare_rock earlier
- Rendering elevation also on polygon alpine_hut and shelter
- Introducing Noto Sans Arabic
- Rendering icon for slipway ways
- Better minimal distance between housenumbers
- Moving aeroways to their own layer
- Creating amenity POI categories
- Some other documentation and code cleaning

## [v4.3.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.2.0...v4.3.0) - 2017-09-16
### Changes
- Moving ford and emergency phone to a new tagging scheme
- Moving natural=tree to higher zoom level (z18+)
- Changing embassy color to brown
- Rendering name for waterway=dock
- The same line wrap of amenities for all zoom levels
- Fixing combined railway/highway ordering regression
- Fixing line wrapping bug in Docker
- Some documentation and code cleaning
- Improve ferry line text legibility
- Hide small theme parks and zoos
- Use solid lines for admin borders at low zooms

## [v4.2.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.1.0...v4.2.0) - 2017-08-25
### Major changes
- Water color and default water text color are changed to be more visible
- Medium zoom level (z8-z12) rework:
  - Landuses colors are faded and some of them are visible earlier
  - Most of the man related landuses are combined into one color and more visible
  - More important roads are better legible

### Changes
- Leaf type rendering in woods and forests
- Cemetary symbols are not so dense now and muslim cemetary has its own symbol
- Rendering of amenity=ferry_terminal
- Plaque rendering is now different and moved to z19
- Rendering railway labels
- Smaller line spaces in labels
- Junction names on areas
- Area color for railway=station is the same as for railways
- Database perfomance tuning available for Docker
- Different patterns and all remaining icons moved to SVG
- Some documentation and code cleaning

## [v4.1.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v4.0.0...v4.1.0) - 2017-07-30
### Changes
- Malls are no longer rendered as dots (bug fix)
- Special icon for shop=tyres
- Airports rendering changes: removing clutter on z10 and moving name labels under the icon
- Switching forest, scrub and quarry patterns to SVG
- Introducing easy to use Docker-based development environment
- New version of script get-shapefiles.py
- Small code and documentation improvements

## [v4.0.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v3.3.0...v4.0.0) - 2017-05-22
### Major changes
- The database schema has changed from the osm2pgsql default. This requires a database reload.
- osm2pgsql Lua transforms are used for some preprocessing. This requires osm2pgsql built with lua support, which most versions will have.

### Changes
- Old-style multipolygons (those with tags on the outer way instead of the relation) are no longer supported
- Multipolygons composed of multiple areas are now rendered with one label
- Fixes to various problems determining if an object is an area or not
- CartoCSS 0.18.0 is required

## [v3.3.1](https://github.com/gravitystorm/openstreetmap-carto/compare/v3.3.0...v3.3.1) - 2017-05-22
### Changes
- Fix a regression in intermittent waterways

## [v3.3.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v3.2.0...v3.3.0) - 2017-05-10
### Changes
- Most shops are now rendered as dots z17 to deal with overcrowding
- Font selection is moved to its own file to make customization easier, and to make it easier for other styles to reuse our font work
- Rare CJK characters outside the BMP should now render better
- Waterway tunnels in forests and lakes are clearer

## [v3.2.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v3.1.0...v3.2.0) - 2017-04-17
### Changes
- Render aeroway terminal buildings like other buildings
- Removed rendering of `landuse=farm`
- Added rendering for arts centre, fitness centre, plant nursery, mixed lift aerialways
- Rendering for fens changed
- Typography for point road-related features, addresses, and water features changed
- Removed rendering of `waterway=canal` as an area
- Take text properties of roads under construction from the type of road they will be

## [v3.1.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v3.0.1...v3.1.0) - 2017-01-28
### Changes
- Added coffee shop rendering
- Added health clinic rendering
- Adjusted place label typography
- Road shield rendering improvements
- Internal code cleanups

## [v3.0.1](https://github.com/gravitystorm/openstreetmap-carto/compare/v3.0.0...v3.0.1) - 2016-12-22
### Changes
- Revert of junction area changes which were preventing index usage

## [v3.0.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.45.1...v3.0.0) - 2016-12-21
### Major Changes
- Mapnik 3 is now required
- CartoCSS 0.16.x is now required
- Official Tilemill support is dropped
- Shapefiles are downloaded with a new python script

### Changes
- Noto Naskh is now used for Arabic
- Visual impact of campsites and quarries reduced below z13
- Wilderness huts rendered
- "ref" (reference) text of subway entrances rendered

## [v2.45.1](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.45.0...v2.45.1) - 2016-12-03
### Changes
- Bug fix for tobacco shop and memorial icons

## [v2.45.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.44.1...v2.45.0) - 2016-11-28
### Changes
- Render all shops without a specific icon as a dot, not just a whitelist
- Scrub pattern change to random
- Change pitch and track color
- Railway stations rendering as major buildings
- Rendering the name of man_made=bridge inside the polygon
- Documentation updates (including cartography design goals and icon design guidelines)
- Icons general code cleaning
- Various bug fixes

## [v2.44.1](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.44.0...v2.44.1) - 2016-10-12
### Changes
- Bug fixes to low zoom place rendering changes
- Documentation improvements for fonts and non-latin rendering

## [v2.44.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.43.0...v2.44.0) - 2016-09-26
### Major Changes
- Rendering of restricted access roads and paths significantly changed
- Changed to use Noto fonts for all languages

### Dependency Changes
- The fonts required have changed

### Changes
- A code of conduct adopted, based on the Go code of conduct
- Adjustments to city wall rendering
- Revised low zoom place rendering
- Fixed oneway arrows on unnamed roads
- Render both house name and number if address has both

## [v2.43.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.42.0...v2.43.0) - 2016-09-05
### Changes
- Adjust alotments pattern
- Whitespace cleanups of code
- Adjust colours of dog parks and construction sites
- Increase font size of addresses
- Fix combination of long names and oneway arrows

## [v2.42.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.41.0...v2.42.0) - 2016-08-03
### Changes
- Add rendering of `amenity=charging_station` and `tourism=artwork`
- Change icon of `shop=department_store`
- Increase font size for various labels
- Change playground color
- Various bug fixes

## [v2.41.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.40.0...v2.41.0) - 2016-07-13
### Changes
- More consistent fonts for POI labels
- Less saturated stadiums
- Rendering obelisks and dog parks
- An updated list of font packages
- Cleaning up the font list
- Rewriting the road colours script for easier changes
- Various bug fixes

### New contributors
- @jdhoek

## [v2.40.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.39.0...v2.40.0) - 2016-06-21
### Changes
- More consistent size of icon labels (bigger labels in most cases).
- Changed rendering of power lines on low zoom levels.
- Changed rendering of turning circles.
- Changed icon for libraries and book shops.
- Larger labels for place names.
- Various bug fixes.

## [v2.39.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.38.0...v2.39.0) - 2016-03-02
### Changes
- Render swing gates
- More SVG icons

## [v2.38.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.37.0...v2.38.0) - 2016-02-17
### Changes
- Add rendering for natural=shoal, and natural=reef.
- Change of rendering of linear barriers: keep rendering of barrier
types `chain`, `city_wall`, `embankment`, `ditch`, `fence`, `guard_rail`,
`handrail`, `hedge`, `kerb`, `retaining_wall`, and `wall`, and drop rendering of
all other barrier types.
- Add rendering for social facilities.
- New icon for sports shops.
- Changed rendering of cutlines.
- Changed rendering for beach surfaces: add rendering for
`surface=fine_gravel`, `surface=pebbles`, and `surface=pebblestone`; drop
rendering for `surface=peeples`
- Various other bug fixes and minor improvements.

## [v2.37.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.36.0...v2.37.0) - 2015-11-30
### Changes
- Improved admin boundaries and labels on low zoom levels
- New farmland colour, making farmland less prominent
- New icons for `shop=copyshop` and `shop=beverages`
- Some refinements to the road rendering, based on the feedback we
received on this topic. In particular, roads are now rendered slightly
narrower on z13, z18 and z19.
- Various other bug fixes and minor improvements.

## [v2.36.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.35.0...v2.36.0) - 2015-10-30
### Major Changes
Major rewrite of road and railway rendering, as part of Mateusz Konieczny's Google Summer of Code project. See https://blog.openstreetmap.org/2015/10/30/openstreetmap-org-map-changing/
for more information.

### Changes
- Added rendering of the following tags:
  - `amenity=fountain`
  - `amenity=car_wash`
  - `historic=wayside_cross` and `man_made=cross`
  - `shop=bag`
  - `shop=outdoor`
  - `power=plant` (labels)
- Changed rendering of the following objects:
  - Placenames (new algorithm for deciding what placenames to render
on low zoomlevels)
  - Road shields
  - Oneway arrows
  - Glaciers
  - Marina labels
  - Station labels
- Dropped rendering of the following tags:
  - `amenity=car_sharing` (not relevant for the general public)
  - `shop=antique` (use `shop=antiques`)
  - `shop=betting` (use `shop=lottery` or `shop=bookmaker`)
  - `shop=delicatessen` (use `shop=deli`)
  - `shop=dive` (use `shop=scuba_diving`)
  - `shop=fish` (use `shop=seafood`, `shop=pet`, `shop=angling` or `amenity=fast_food`)
  - `shop=gambling` (use `shop=lottery`, `shop=bookmaker`, or
`leisure=adult_gaming_centre`)
  - `shop=insurance` (use `office=insurance`)
  - `shop=pharmacy` (use `office=pharmacy`)
  - `shop=bags` (use `shop=bag`)
- Various other bug fixes and minor improvements.

## [v2.35.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.34.0...v2.35.0) - 2015-09-16
### Changes
- Add new icon for ford
- Stop rendering of `landuse=conservation`
- Restore rendering of `amenity=kindergarten/school/college/university/grave_yard` names
- Various other bug fixes.

## [v2.34.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.33.0...v2.34.0) - 2015-08-28
### Changes
Changes include

- better rendering for highway=path/footway/cycleway - this is the
next iteration of improving how footways and cycleways are
displayed. Unpaved footways are now visible on natural=bare_rock
and there are now three classes: paved, unpaved and unknown surface

- `man_made=bridge` is now rendered

- new rendering for `landuse=quarry`

- `amenity=veterinary` is now rendered

- `amenity=community_centre` is now rendered

- `amenity=prison` and `landuse=military` rendering takes in account area size

- consistent color for boundaries

- tweaked zoom level for `amenity=car_sharing` and `amenity=car_rental`

- Mapnik 3 preparations are now finished. The style now supports Mapnik 3. Most of the work was done on the Mapnik side.

## [v2.33.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.32.0...v2.33.0) - 2015-08-14
### Major changes
- A randomized symbology for forests for `natural=wood` and `landuse=forest`

  A long time in the works, this improvement has finally landed. The two
  tags were merged - they are indistinguishable to the data consumer.
  A randomized symbology was first suggested by SK53 at SOTM-EU 2014,
  and this feature would not have happened without his extensive research,
  or imagico's tools for creating an irregular but uniformly distributed
  and periodic dot pattern

- Unification of footway/path and rendering surface of them

   The mess that is highway=path is well-known, and it is necessary
   to do some kind of processing as a data consumer. A distinction is
   now made between paved and unpaved footways.


### Changes
- Mapnik 3 preperations

   The style is not yet fullly tested with Mapnik 3 and we don't claim to
   support it, but several bugs were fixed. Most of the work was done on
   the Mapnik side

- Power area colour adjusted

## [v2.32.0](https://github.com/gravitystorm/openstreetmap-carto/compare/v2.31.0...v2.32.0) - 2015-07-31
# New files

Shapefiles are now used for Antartic ice sheets

### Changes

- Rendering minor roads and service rail later for mid-zoom clarity

   As all residential, unclassified, and service roads in a city became
   mapped the rendered view became over-crowded, bloblike, and difficult
   to read.

- Rendering of Antartic ice sheets from shapefiles

  Ice sheets in Antartica are a bit of a special case, and pre-generated
  shapefiles are now used

- No longer rendering proposed roads

- Better place label order

- meadow/grassland and orchard/vineyard color unification

- Render educational area borders later

- New POI icons