--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.5
-- Dumped by pg_dump version 9.5.5

-- This script can be used to create the necessary views on an Osm2pgsql
-- database which has been imported using the OSM Carto Lua style.

BEGIN;

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

DROP VIEW IF EXISTS public.view_osmde_roads;
DROP VIEW IF EXISTS public.view_osmde_polygon;
DROP VIEW IF EXISTS public.view_osmde_point;
DROP VIEW IF EXISTS public.view_osmde_line;
SET search_path = public, pg_catalog;

/* Generate a floating point number from a numeric OSM tag

   Unfortunately this contains a lot of heuristic :(

  This function is handy for the generation of a numeric pseudo column
  in a database view.

  (c) 2016 Sven Geggus <sven-osm@geggus.net>

*/
CREATE or REPLACE FUNCTION osm_tag2num(tag text) RETURNS REAL AS $$
 DECLARE
  num real;
  feet boolean;
 BEGIN
   feet=false;
   /* remove potential crap inside parentheses */
   tag=regexp_replace(tag, '\(.*\)', '', 'gi');
   /* remove leading or trailing whitespace */
   tag=regexp_replace(tag, '^\s+(.*)\s+$', '\1', 'g');
   
   /* check if unit is given in feet and convert later*/
   if (right(tag,2) = 'ft') THEN feet=true; END IF;
   if (right(tag,3) = 'ft.') THEN feet=true; END IF;
   if (right(tag,4) = 'feet') THEN feet=true; END IF;
   if (right(tag,1) = '′') THEN feet=true; END IF;
   if (right(tag,1) = '''') THEN feet=true; END IF;
   
   /* general assumption:
      <alphanumeric_string>.<somenumber> should be interpreted as
      <somenumber> not 0.<somenumber>
      <alphanumeric_string> .<somenumber> should be interpreted as
      0.<somenumber>
      
      So get just get rid of the dot in strings of the form
      <alphanumeric_string>.<somenumber>
      Example:
      ca.5m
      
   */
   tag=regexp_replace(tag, '([[:alpha:]])\.([0-9])', '\1 \2', 'gi');
   
   /* remove the remaining leading and trailing garbage */
   tag=regexp_replace(tag, '^[[:alpha:]:~ ><]*\.?? *([^ [:alpha:]]*) *[ [:alpha:]′''\.]*$', '\1', 'gi');

   /* , seems to be used more often in its german form as a
    decimal mark rather than as a thousands separator so let's
    asume that this is always the case */
   tag=replace(tag, ',', '.');

   BEGIN
     num=tag::real;
   EXCEPTION WHEN OTHERS THEN
     -- RAISE NOTICE 'Invalid integer value: "%".  Returning NULL.', tag;
     num=NULL;
   END;
   /* convert feet to meters */
   if feet THEN num=0.3048*num; END IF;
   return num;
 END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION add_name_to_hstore(existing hstore, name text) RETURNS hstore AS $$
--  SELECT existing || ('name=>' || name)::hstore;
  SELECT
    CASE
      WHEN name IS NOT NULL THEN existing || ('name=>' || name::text)::hstore
      ELSE existing 
    END AS result;
$$ LANGUAGE SQL IMMUTABLE;

CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
CREATE EXTENSION IF NOT EXISTS osml10n;
CREATE EXTENSION IF NOT EXISTS plpython3u;
CREATE EXTENSION IF NOT EXISTS osml10n_thai_transcript;

--
-- Name: view_osmde_line; Type: VIEW; Schema: public; Owner: ${DB_SUPERUSER}
--

CREATE VIEW view_osmde_line AS
 SELECT planet_osm_line.osm_id,
    planet_osm_line.access,
    planet_osm_line."addr:interpolation",
    planet_osm_line.aerialway,
    planet_osm_line.aeroway,
    planet_osm_line.barrier,
    planet_osm_line.bicycle,
    planet_osm_line.bridge,
    planet_osm_line.building,
    planet_osm_line.construction,
    planet_osm_line.covered,
    planet_osm_line.tags->'culvert' AS culvert,
    (planet_osm_line.tags -> 'disused'::text) AS disused,
    planet_osm_line.tags->'embankment' AS embankment,
    planet_osm_line.foot,
    planet_osm_line.highway,
    planet_osm_line.historic,
    planet_osm_line.horse,
    (planet_osm_line.tags -> 'intermittent'::text) AS intermittent,
    planet_osm_line.junction,
    planet_osm_line.layer AS layer, -- column is integer, we don't cast
    planet_osm_line.leisure,
    planet_osm_line.lock,
    planet_osm_line.man_made,
    planet_osm_line.military,
    planet_osm_line.tags->'name:en' AS "name:en",
    planet_osm_line."natural",
    planet_osm_line.oneway,
    (planet_osm_line.tags -> 'operator'::text) AS operator,
    planet_osm_line.power AS "power",
    planet_osm_line.tags->'proposed' AS "proposed",
    planet_osm_line.railway,
    planet_osm_line.ref,
    planet_osm_line.route,
    planet_osm_line.service,
    planet_osm_line.surface,
    planet_osm_line.tracktype,
    planet_osm_line.tunnel,
    planet_osm_line.waterway,
    planet_osm_line.tags->'width' AS width,
    osm_tag2num(planet_osm_line.tags->'width') as "num_width",
    planet_osm_line.way,
    planet_osm_line.way_area,
    planet_osm_line.z_order,
    planet_osm_line.tags AS "tags",
    planet_osm_line.name,
    osml10n_get_placename_from_tags(tags ,true,false,' - ', 'en', way, planet_osm_line.name) as localized_name_second,
    osml10n_get_placename_from_tags(tags, false,false,' - ', 'en', way, planet_osm_line.name) as localized_name_first,
    osml10n_get_name_without_brackets_from_tags(tags, 'en', way, planet_osm_line.name) as localized_name_without_brackets,
    osml10n_get_streetname_from_tags(tags, true, false, ' - ', 'en', way, planet_osm_line.name) as localized_streetname
   FROM planet_osm_line;


ALTER TABLE view_osmde_line OWNER TO ${DB_SUPERUSER};

--
-- Name: view_osmde_point; Type: VIEW; Schema: public; Owner: ${DB_USER}
--

CREATE VIEW view_osmde_point AS
 SELECT planet_osm_point.osm_id,
    planet_osm_point.access,
    planet_osm_point."addr:housename",
    planet_osm_point."addr:housenumber",
    planet_osm_point.admin_level,
    planet_osm_point.aerialway,
    planet_osm_point.aeroway,
    planet_osm_point.amenity,
    planet_osm_point.barrier,
    planet_osm_point.boundary,
    planet_osm_point.building,
    (planet_osm_point.tags -> 'capital'::text) AS capital,
    (planet_osm_point.tags -> 'denomination'::text) AS denomination,
    (planet_osm_point.tags -> 'ele'::text) AS ele,
    osm_tag2num(planet_osm_point.tags -> 'ele'::text) AS num_ele,
    (planet_osm_point.tags -> 'generator:source'::text) AS "generator:source",
    planet_osm_point.highway,
    planet_osm_point.historic,
    planet_osm_point.tags->'iata' AS iata,
    planet_osm_point.junction,
    planet_osm_point.landuse,
    planet_osm_point.leisure,
    planet_osm_point.man_made,
    planet_osm_point.military,
    planet_osm_point.tags->'name:de' AS "name:de",
    planet_osm_point."natural",
    (planet_osm_point.tags -> 'operator'::text) AS operator,
    planet_osm_point.place,
    (planet_osm_point.tags -> 'population'::text) AS population,
    planet_osm_point.power,
    (planet_osm_point.tags -> 'power_source'::text) AS power_source,
    planet_osm_point.railway,
    planet_osm_point.ref,
    planet_osm_point.religion,
    planet_osm_point.tags->'ruins' AS ruins,
    planet_osm_point.shop,
    planet_osm_point.tags->'sport' AS sport,
    planet_osm_point.tourism,
    planet_osm_point.waterway,
    planet_osm_point.tags->'wetland' AS wetland,
    planet_osm_point.way,
    planet_osm_point.tags->'width' as "width",
    osm_tag2num(planet_osm_point.tags->'width') as "num_width",
    planet_osm_point.tags AS "tags",
    planet_osm_point.name,
    osml10n_get_placename_from_tags(tags ,true,false,chr(10), 'en', way, planet_osm_point.name) as localized_name_second,
    osml10n_get_placename_from_tags(tags, false,false,chr(10), 'en', way, planet_osm_point.name) as localized_name_first,
    osml10n_get_name_without_brackets_from_tags(tags, 'en', way, planet_osm_point.name) as localized_name_without_brackets,
    osml10n_get_streetname_from_tags(tags, true, false, chr(10), 'en', way, planet_osm_point.name) as localized_streetname,
    layer as layer
   FROM planet_osm_point;


ALTER TABLE view_osmde_point OWNER TO ${DB_USER};

--
-- Name: view_osmde_polygon; Type: VIEW; Schema: public; Owner: ${DB_SUPERUSER}
--

CREATE VIEW view_osmde_polygon AS
 SELECT planet_osm_polygon.osm_id,
    planet_osm_polygon.access,
    planet_osm_polygon."addr:housename",
    planet_osm_polygon."addr:housenumber",
    planet_osm_polygon.admin_level,
    planet_osm_polygon.aerialway,
    planet_osm_polygon.aeroway,
    planet_osm_polygon.amenity,
    planet_osm_polygon.barrier,
    planet_osm_polygon.bicycle,
    planet_osm_polygon.boundary,
    planet_osm_polygon.bridge,
    planet_osm_polygon.building,
    planet_osm_polygon.covered,
    (planet_osm_polygon.tags -> 'denomination'::text) AS denomination,
    (planet_osm_polygon.tags -> 'generator:source'::text) AS "generator:source",
    planet_osm_polygon.highway,
    planet_osm_polygon.historic,
    planet_osm_polygon.tags->'iata' AS iata,
    planet_osm_polygon.junction,
    planet_osm_polygon.landuse,
    planet_osm_polygon.tags->'leaf_type' AS leaf_type,
    planet_osm_polygon.layer AS layer,
    planet_osm_polygon.leisure,
    planet_osm_polygon.man_made,
    planet_osm_polygon.military,
    planet_osm_polygon.tags->'name:de' AS "name:de",
    planet_osm_polygon."natural",
    (planet_osm_polygon.tags -> 'operator'::text) AS operator,
    planet_osm_polygon.place,
    planet_osm_polygon.power,
    (planet_osm_polygon.tags -> 'power_source'::text) AS power_source,
    planet_osm_polygon.railway,
    planet_osm_polygon.ref,
    planet_osm_polygon.religion,
    planet_osm_polygon.tags->'ruins' AS ruins,
    planet_osm_polygon.shop,
    planet_osm_polygon.tags->'sport' AS sport,
    planet_osm_polygon.surface,
    planet_osm_polygon.tourism,
    planet_osm_polygon.tunnel,
    planet_osm_polygon.water,
    planet_osm_polygon.waterway,
    (planet_osm_polygon.tags -> 'wetland'::text) AS wetland,
    osm_tag2num(planet_osm_polygon.tags->'width') AS "num_width",
    planet_osm_polygon.way,
    planet_osm_polygon.way_area,
    planet_osm_polygon.z_order,
    planet_osm_polygon.tags AS "tags",
    planet_osm_polygon.name,
    osml10n_get_placename_from_tags(tags, true,false,chr(10), 'en', way, planet_osm_polygon.name) as localized_name_second,
    osml10n_get_placename_from_tags(tags, false,false,chr(10), 'en', way, planet_osm_polygon.name) as localized_name_first,
    osml10n_get_name_without_brackets_from_tags(tags, 'en', way, planet_osm_polygon.name) as localized_name_without_brackets,
    osml10n_get_streetname_from_tags(tags, true, false, chr(10), 'en', way, planet_osm_polygon.name) as localized_streetname,
    osml10n_get_country_name(tags, chr(10), 'en') as country_name
  FROM planet_osm_polygon;


ALTER TABLE view_osmde_polygon OWNER TO ${DB_SUPERUSER};

--
-- Name: view_osmde_roads; Type: VIEW; Schema: public; Owner: ${DB_SUPERUSER}
--

CREATE VIEW view_osmde_roads AS
 SELECT planet_osm_roads.osm_id,
    planet_osm_roads.admin_level,
    planet_osm_roads.covered,
    planet_osm_roads.highway,
    (planet_osm_roads.tags -> 'name:de'::text) AS "name:de",
    (planet_osm_roads.tags -> 'int_name'::text) AS int_name,
    (planet_osm_roads.tags -> 'name:en'::text) AS "name:en",
    planet_osm_roads.railway,
    planet_osm_roads.ref,
    planet_osm_roads.service,
    planet_osm_roads.surface,
    planet_osm_roads.tunnel,
    planet_osm_roads.z_order,
    planet_osm_roads.aerialway as "aerialway",
    planet_osm_roads."addr:housenumber" as "addr:housenumber",
    planet_osm_roads.aeroway as "aeroway",
    planet_osm_roads.amenity as "amenity",
    planet_osm_roads.barrier as "barrier",
    planet_osm_roads.boundary as "boundary",
    planet_osm_roads.building as "building",
    planet_osm_roads.historic as "historic",
    planet_osm_roads.lock as "lock",
    planet_osm_roads.man_made as "man_made",
    planet_osm_roads.power as "power",
    planet_osm_roads.route as "route",
    planet_osm_roads.shop as "shop",
    planet_osm_roads.waterway as "waterway",
    planet_osm_roads.tags->'width' as "width",
    planet_osm_roads.way,
    planet_osm_roads.name,
    osml10n_get_placename_from_tags(tags,true,false,' - ','en',way, planet_osm_roads.name) as localized_name_second,
    osml10n_get_placename_from_tags(tags,false,false,' - ','en',way, planet_osm_roads.name) as localized_name_first,
    osml10n_get_name_without_brackets_from_tags(tags,'en',way, planet_osm_roads.name) as localized_name_without_brackets,
    osml10n_get_streetname_from_tags(tags,true,false,' - ','en', way, planet_osm_roads.name) as localized_streetname,
    planet_osm_roads.layer as layer,
    planet_osm_roads.tags as tags
   FROM planet_osm_roads;


ALTER TABLE view_osmde_roads OWNER TO ${DB_SUPERUSER};

--
-- Name: view_osmde_line; Type: ACL; Schema: public; Owner: ${DB_SUPERUSER}
--

REVOKE ALL ON TABLE view_osmde_line FROM PUBLIC;
REVOKE ALL ON TABLE view_osmde_line FROM ${DB_SUPERUSER};
GRANT ALL ON TABLE view_osmde_line TO ${DB_SUPERUSER};
GRANT ALL ON TABLE view_osmde_line TO ${DB_USER};


--
-- Name: view_osmde_point; Type: ACL; Schema: public; Owner: ${DB_USER}
--

REVOKE ALL ON TABLE view_osmde_point FROM PUBLIC;
REVOKE ALL ON TABLE view_osmde_point FROM ${DB_USER};
GRANT ALL ON TABLE view_osmde_point TO ${DB_USER};


--
-- Name: view_osmde_polygon; Type: ACL; Schema: public; Owner: ${DB_SUPERUSER}
--

REVOKE ALL ON TABLE view_osmde_polygon FROM PUBLIC;
REVOKE ALL ON TABLE view_osmde_polygon FROM ${DB_SUPERUSER};
GRANT ALL ON TABLE view_osmde_polygon TO ${DB_SUPERUSER};
GRANT ALL ON TABLE view_osmde_polygon TO ${DB_USER};


--
-- Name: view_osmde_roads; Type: ACL; Schema: public; Owner: ${DB_SUPERUSER}
--

REVOKE ALL ON TABLE view_osmde_roads FROM PUBLIC;
REVOKE ALL ON TABLE view_osmde_roads FROM ${DB_SUPERUSER};
GRANT ALL ON TABLE view_osmde_roads TO ${DB_SUPERUSER};
GRANT ALL ON TABLE view_osmde_roads TO ${DB_USER};


--
-- PostgreSQL database dump complete
--

COMMIT;
