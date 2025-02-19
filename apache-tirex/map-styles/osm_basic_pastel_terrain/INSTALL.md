# Installation

## OpenStreetMap data
You need OpenStreetMap data loaded into a PostGIS database (see below for [dependencies](#dependencies)). These stylesheets currently work only with the osm2pgsql defaults (i.e. database name is `gis`, table names are `planet_osm_point`, etc).

It's probably easiest to grab an PBF of OSM data from [Geofabrik](http://download.geofabrik.de/). Once you've set up your PostGIS database, import with osm2pgsql:

```
osm2pgsql -d gis ~/path/to/data.osm.pbf --style openstreetmap-carto.style
```

You can find a more detailed guide to setting up a database and loading data with osm2pgsql at [switch2osm.org](http://switch2osm.org/loading-osm-data/).

### Custom indexes
Custom indexes are not required, but will speed up rendering, particularly for full planet databases, heavy load, or other production environments. They will not be as helpful with development using small extracts.

```
psql -d gis -f indexes.sql
```

Additionally you need some shapefiles.

## Scripted download
To download the shapefiles you can run the following script. No further steps should be needed as the data has been processed and placed in the requisite directories.

```
scripts/get-shapefiles.py
```

This script generates and populates the *data* directory with all needed shapefiles, including indexing them through *shapeindex*.

## Manual download

You can also download them manually at the following paths:

* [`simplified-land-polygons.shp`](https://osmdata.openstreetmap.de/simplified-land-polygons-complete-3857.zip) (updated daily)
* [`land-polygon.shp`](https://osmdata.openstreetmap.de/land-polygons-split-3857.zip) (updated daily)
* [`builtup_area.shp`](https://planet.openstreetmap.org/historical-shapefiles/world_boundaries-spherical.tgz)
* [`ne_110m_admin_0_boundary_lines_land.shp`](http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/ne_110m_admin_0_boundary_lines_land.zip)

The repeated www.naturalearthdata.com in the Natural Earth shapefiles is correct.

Put these shapefiles at `path/to/openstreetmap-carto/data`.

## Hillshade

This map style requires a hillshade. It should be provided as GeoTIFF tiles in Web Mercator projection (EPSG:3857).
Three tile sets need to be provided. Each of them has to have a .vrt index file called `index.vrt`.

* `data/index.vrt` – high resolution hillshade (tiles 2.5° x 2.5°, 2160 x 2161 pixel)
* `data/small/index.vrt` – hillshade for medium zoom levels (tiles 2.5° x 2.5°, 1240 x 1240 pixel)
* `data/tiny/index.vrt` – hillshade for low zoom levels (tiles 40° x 40°, 4000 x 4000 pixel)

The size of the tiles is not a hard requirement but the paths to the .vrt files are. The hillshade for
medium and small zoom levels has to have that resolution (or a smaller one) because Mapnik will fail rendering
due to a too large number of pixels of the input raster dataset (that's the reason why there is the "tiny" hillshade).

You can generate the hillshade from raw SRTM/ASTER data using `gdaldem hillshade -combined`. See the GDAL documentation for details.

## Contours

Contours are read from a PostGIS database named `contours`.

## Polygon of German speaking area

Labeling in the German speaking area should follow different rules than outside. Therefore, the database needs a table `german_tiled`.
Populate it using the following command:

```sh
shp2pgsql -s 3857 -cDI shapefiles/german_tiled.shp german_tiled gis | psql -d gis
```

## Fonts
The stylesheet uses Noto Sans, an openly licensed font from Google with support for multiple scripts. The "UI" version is used where available, with its vertical metrics which fit better with Latin text. Other fonts from the Noto family are used for some other languages.

DejaVu Sans is used as an optional fallback font for systems without Noto Sans. If all the Noto fonts are installed, it should never be used.

Unifont is used as a last resort fallback, with it's excellent coverage, common presence on machines, and ugly look.

On Ubuntu 16.04 or Debian Testing you can install the required fonts except Noto Emoji Regular with

```
sudo apt-get install fonts-noto-cjk fonts-noto-hinted fonts-noto-unhinted ttf-unifont
```

Noto Emoji Regular can be downloaded [from the Noto Emoji repository](https://github.com/googlei18n/noto-emoji).

It might be useful to have a more recent version of the fonts for [rare non-latin scripts](#non-latin-scripts). This can be installed [from source](https://github.com/googlei18n/noto-fonts/blob/master/FAQ.md#where-are-the-fonts).

DejaVu is packaged as `fonts-dejavu-core`.

### Non-latin scripts

For proper rendering of non-latin scripts, particularly those with complicated diacritics and tone marks the requirements are

* FreeType 2.6.2 or later for CJK characters

* A recent enough version of Noto with coverage for the scripts needed.

## Dependencies

For development, a style design studio is needed.
* [Kosmtik](https://github.com/kosmtik/kosmtik) - Kosmtik can be launched with `node index.js serve path/to/openstreetmap-carto/project.mml`

For deployment, CartoCSS and Mapnik are required.

* [CartoCSS](https://github.com/mapbox/carto) >= 0.16.0 (we're using YAML)
* [Mapnik](https://github.com/mapnik/mapnik/wiki/Mapnik-Installation) >= 3.0

Remember to run CartoCSS with proper API version to avoid errors (at least 3.0.0: `carto -a "3.0.0"`).

---

For both development and deployment, a database and some utilities are required

* [osm2pgsql](http://wiki.openstreetmap.org/wiki/Osm2pgsql) to [import your data](https://switch2osm.org/loading-osm-data/) into a PostGIS database
* [PostgreSQL](http://www.postgresql.org/)
* [PostGIS](http://postgis.org/)
* `curl` and `unzip` for downloading and decompressing files
* shapeindex (a companion utility to Mapnik found in the mapnik-utils package) for indexing downloaded shapefiles

### Development dependencies

Some colours, SVGs and other files are generated with helper scripts. Not all users will need these dependencies

* Python and Ruby to run helper scripts
* [Color Math](https://github.com/gtaylor/python-colormath) and [numpy](http://www.numpy.org/) if running generate_road_colors.py helper script (may be obtained with `pip install colormath numpy`)
