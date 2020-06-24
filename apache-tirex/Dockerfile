FROM ubuntu:20.04
MAINTAINER Philip Beelmann <beelmann@geofabrik.de>

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    gdal-bin \
    node-carto \
    libwww-perl \
    apache2 \
    libmapnik3.0 \
    mapnik-utils \
    libjson-perl \
    libipc-sharelite-perl \
    libgd-gd2-perl \
    unzip \
    git \
    ttf-dejavu \
    ttf-unifont \
    fonts-sipa-arundina \
    fonts-sil-padauk \
    fonts-khmeros \
    fonts-taml-tscu \
    python-yaml \
    npm \
    postgresql-client \
    libnet-https-nb-perl \
    libhttp-async-perl \
    patch \
    gettext \
    wait-for-it \
    postgis \
    python \
    wget \
    curl \
    xinetd \
    rsyslog

COPY thirdparty/debs /tmp/debs
RUN dpkg -i /tmp/debs/*deb

# setup styles in tirex
COPY tirex-mapnik-styles/* /etc/tirex/renderer/mapnik/
COPY tirex-tms-styles/topplusopen.env.conf /etc/tirex/renderer/tms/templates/

# copy styles
COPY map-styles/openstreetmap-carto-de /srv/openstreetmap-carto-de
COPY map-styles/osm_basic_pastel_terrain /srv/osm_basic_pastel_terrain

RUN mkdir /style-data && \
    ln -sf /style-data /srv/openstreetmap-carto-de/data && \
    ln -sf /style-data /srv/osm_basic_pastel_terrain/data

RUN \
# get additional data for styles
   cd /srv/osm_basic_pastel_terrain \
&& ./scripts/get-shapefiles.py \
&& cd /srv/openstreetmap-carto-de \
&& ./scripts/get-shapefiles.py

# copy patches
COPY patches/* /tmp/

RUN \
# configure tirex
    patch -l /etc/tirex/tirex.conf < /tmp/tirex.conf.patch \
 && patch -l /etc/tirex/renderer/mapnik.conf < /tmp/mapnik.conf.patch \
# setup tile directories
 && install -d -o tirex -g tirex /var/lib/tirex/tiles/osmde/ \
 && install -d -o tirex -g tirex /var/lib/tirex/tiles/osmde2x/ \
 && install -d -o tirex -g tirex /var/lib/tirex/tiles/basicpastel/ \
 && install -d -o tirex -g tirex /var/lib/tirex/tiles/basicpastel2x/ \
 && install -d -o tirex -g tirex /var/lib/tirex/tiles/bfs-labels-only/ \
 && install -d -o tirex -g tirex /var/lib/tirex/tiles/bfs-labels-only2x/ \
 && install -d -o tirex -g tirex /var/lib/tirex/tiles/topplusopen/ \
 && rm -rf /var/lib/mod_tile \
 && ln -s /var/lib/tirex/tiles /var/lib/mod_tile \
 && chown tirex:tirex -R /var/lib/tirex/tiles/ \
 && mkdir -p /etc/tirex/renderer/tms/templates/ \
 && rm -f /etc/tirex/renderer/tms/demotms.conf \
 && rm -rf /etc/tirex/renderer/test \
 && rm -f /etc/tirex/renderer/test.conf

# patch styles
RUN \
    patch -l /srv/openstreetmap-carto-de/project.mml                < /tmp/osmde_project.mml.patch \
 && patch -l /srv/osm_basic_pastel_terrain/project.mml              < /tmp/basicpastel_project.mml.patch \
 && patch -l /srv/osm_basic_pastel_terrain/bfs-labels-only.mml      < /tmp/basicpastel_bfs-labels-only.mml.patch \
 && patch -l /srv/openstreetmap-carto-de/views_osmde/views-lua.sql  < /tmp/views-lua.sql.patch \
 && mv /srv/openstreetmap-carto-de/views_osmde/views-lua.sql /srv/openstreetmap-carto-de/views_osmde/views-lua.env.sql \
 && npm install -g carto \
 && carto /srv/openstreetmap-carto-de/project.mml            > /srv/openstreetmap-carto-de/osmde.env.xml \
 && carto /srv/osm_basic_pastel_terrain/project.mml          > /srv/osm_basic_pastel_terrain/basicpastel.env.xml \
 && carto /srv/osm_basic_pastel_terrain/bfs-labels-only.mml  > /srv/osm_basic_pastel_terrain/bfs-labels-only.env.xml

COPY tileserver_site.conf /etc/apache2/sites-available/
COPY frontend/* /var/www/html/
COPY scripts/* /usr/local/bin/

COPY thirdparty/checkmk-plugins/apache_status /usr/lib/check_mk_agent/plugins/
COPY thirdparty/checkmk-plugins/apache_status.cfg /etc/check_mk/

EXPOSE 80
EXPOSE 6556

CMD /usr/local/bin/start.sh

VOLUME ["/style-data"]

HEALTHCHECK --start-period=10m CMD curl http://localhost/tiles/osmde/0/0/0.png
