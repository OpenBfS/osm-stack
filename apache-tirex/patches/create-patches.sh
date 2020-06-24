#!/bin/bash

diff ../map-styles/openstreetmap-carto-de/project.mml osmde_project.mml > osmde_project.mml.patch
diff ../map-styles/osm_basic_pastel_terrain/project.mml basicpastel_project.mml > basicpastel_project.mml.patch
diff ../map-styles/osm_basic_pastel_terrain/bfs-labels-only.mml basicpastel_bfs-labels-only.mml > basicpastel_bfs-labels-only.mml.patch
diff ../map-styles/openstreetmap-carto-de/views_osmde/views-lua.sql views-lua.sql > views-lua.sql.patch

echo done
