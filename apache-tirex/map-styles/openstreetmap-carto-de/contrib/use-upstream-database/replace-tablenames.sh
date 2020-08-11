#!/bin/sh

sed -e 's!planet_osm_line!planet_osm_line_de!g' \
    -e 's!planet_osm_point!planet_osm_point_de!g' \
    -e 's!planet_osm_polygon!planet_osm_polygon_de!g' \
    -e 's!planet_osm_roads!planet_osm_roads_de!g' \
    ../../project.mml > ../../project-mod.mml

