#! /usr/bin/env python3

import configparser
import psycopg2

service_name = "PostgreSQL Validity of Geometries"

# Read configuration
config = configparser.ConfigParser()
config.read("/etc/pg_replication_checker.conf")

publisher_dbname = config["publisher"]["dbname"]
subscriber_dbname = config["subscriber"]["dbname"]
is_master = (str(config["general"]["is_master"]) == "1")
critical_level = int(config["thresholds"]["broken_geoms_critical"])
warn_level = int(config["thresholds"]["broken_geoms_warn"])

# select st_setsrid( st_makebox2d( st_makepoint(-20037509,-1114), st_makepoint(20037509,1114)), 3857);
bbox_equator = "0103000020110F0000010000000500000000000050F81B73C100000000006891C000000050F81B73C1000000000068914000000050F81B7341000000000068914000000050F81B734100000000006891C000000050F81B73C100000000006891C0"
# st_setsrid( st_makebox2d( st_makepoint(-20037509,5621521), st_makepoint(20037509,5623096)), 3857)
bbox_45n = "0103000020110F0000010000000500000000000050F81B73C100000040C471554100000050F81B73C1000000004E73554100000050F81B7341000000004E73554100000050F81B734100000040C471554100000050F81B73C100000040C4715541"
# st_setsrid( st_makebox2d( st_makepoint(-20037509,-5623096), st_makepoint(20037509,-5621521)), 3857)
bbox_45s = "0103000020110F0000010000000500000000000050F81B73C1000000004E7355C100000050F81B73C100000040C47155C100000050F81B734100000040C47155C100000050F81B7341000000004E7355C100000050F81B73C1000000004E7355C1"

dbname = publisher_dbname
if not is_master:
    dbname = subscriber_dbname

count = 0
with psycopg2.connect("dbname={} user=postgres".format(dbname)) as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT count(1) FROM planet_osm_line WHERE way && %s AND way && %s AND way && %s", (bbox_equator, bbox_45n, bbox_45s,))
        count = cur.fetchone()[0]

status = "0" # unknown
status_text = "The database contains no geometries which might be broken."
if count > critical_level:
    status = "2"
    status_text = "The database contains some geometries which could be broken ({} lines).".format(count)
elif count > warn_level:
    status = "1"
    status_text = "The database contains some geometries which could be broken ({} lines).".format(count)
elif count < 0:
    status = "3"
    status_text = "The validity of geometries could not be check, weird database response."
values = {"value": count, "warn": warn_level, "crit": critical_level, "min": 0, "max": ""}
values_str = "{value};{warn};{crit};{min};{max}".format(**values)

out_text = '{} "{}" likely_broken_geometries={} {}'.format(status, service_name, values_str, status_text)
print(out_text)
