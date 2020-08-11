<?php
@define('CONST_Database_DSN', 'pgsql:dbname=' . (getenv('DB_NAME') ?? 'nominatim') . ';host=' . (getenv('DB_HOST') ?? 'nominatim-postgres-master') . ';user=' . (getenv('DB_USER') ?? 'nominatim') . ';password=' . getenv('DB_PASSWORD') . "\'");
@define('CONST_Pyosmium_Binary', '/usr/local/bin/pyosmium-get-changes');
@define('CONST_Import_Style', CONST_BasePath.'/settings/import-address-postcode-polygons-preserve.style');
if(getenv('FLAT_NODES') == '1') {
	@define('CONST_Osm2pgsql_Flatnode_File', '/flatnodes/fn');
} else {
	@define('CONST_Osm2pgsql_Flatnode_File', '');
}
if (getenv('REPLICATION_URL') === FALSE) {
    echo 'The environment variable REPLICATION_URL is not set. If it cannot be retrieved from the .osm.pbf file, it needs to be set by Docker.\n';
    exit(1);
}
//@define('CONST_Replication_Url', 'http://download.geofabrik.de/europe/germany/bremen-updates');
// If you want to use HTTPS for download.geofabrik.de although the .osm.pbf file sets http://, comment out the next line.
@define('CONST_Replication_Url', preg_replace('/^http:\/\/download\.geofabrik\.de\//', 'https://download.geofabrik.de/', getenv('REPLICATION_URL')));
@define('CONST_Replication_Url', getenv('REPLICATION_URL'));
@define('CONST_Replication_Update_Interval', getenv('UPDATE_INTERVAL') ?? '86400');
@define('CONST_Replication_Recheck_Interval', getenv('UPDATE_RECHECK_INTERVAL') ?? '900');
