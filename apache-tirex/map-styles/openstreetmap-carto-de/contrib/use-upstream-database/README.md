
The files in this directory will aid you in using a database created for
 our upstream-style, "openstreetmap-carto". This can be useful for example
 if you want to render both styles from the same databse.

The upstream "openstreetmap-carto" style uses a database that has some
 frequently used tags in extra columns, and the seldomly used ones in a
 hstore, while "openstreetmap-carto-de" instead uses a database where
 everything is put into hstore.

To use an upstream-style database, two things need to be done:
* Views that translate from the field names the -de style expects to the
  ones that actually exist in the database need to be created.
* All references to tablenames in `project.mml` need to be adapted to
  reference the views instead of the real tables.

For defining the views, execute all *.sql files in this directory, i.e.

```
 psql -d osm -f view-line.sql
 psql -d osm -f view-point.sql
 psql -d osm -f view-polygon.sql
 psql -d osm -f view-roads.sql
```

For replacing the tablenames in `project.mml`, execute the script `replace-tablenames.sh`
 in this directory. It will create a new file `project-mod.mml` from `project.mml`,
 where the tablenames have been replaced. You will then need to compile this
 `project-mod.mml` with carto, not the original `project.mml`.
 Alternatively, you can of course simply manually append an `_de` to all
 tablenames in the SQL queries in `project.mml`.

Note that most of the rest of the setup instructions for openstreetmap-carto-de
 still apply, in particular you still need to set up the i10n stuff on your
 database.

