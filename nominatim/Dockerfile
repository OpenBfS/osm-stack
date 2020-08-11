FROM ubuntu:20.04

ARG NOMINATIM_TARBALL_URL
ARG PHOTON_ZIP_URL_BASE
ARG PHOTON_BRANCH_TAG

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y wget build-essential cmake g++ libboost-dev libboost-system-dev libboost-filesystem-dev libexpat1-dev zlib1g-dev libxml2-dev libbz2-dev libpq-dev libproj-dev php php-pgsql php-intl postgresql-server-dev-12 python3-psycopg2 python3-pip openjdk-11-jdk maven postgresql-client-12 unzip wait-for-it osmium-tool

RUN pip3 install osmium

RUN mkdir -p /nominatim && mkdir -p /photon/photon-$PHOTON_BRANCH_TAG

RUN cd /nominatim && wget --quiet -O nominatim.tar.bz2 $NOMINATIM_TARBALL_URL && tar -xjf nominatim.tar.bz2 &&  mv Nominatim-*/* . && rm -rf Nominatim-* && rm nominatim.tar.bz2 && mkdir -p build && cd build && cmake -DPYOSMIUM=/usr/local/bin/pyosmium-get-changes .. && make -s -j2

RUN cd /nominatim/data && wget --quiet -O country_osm_grid.sql.gz https://www.nominatim.org/data/country_grid.sql.gz && wget --quiet -O wikipedia_article.sql.bin https://www.nominatim.org/data/wikipedia_article.sql.bin && wget --quiet -O wikipedia_redirect.sql.bin https://www.nominatim.org/data/wikipedia_redirect.sql.bin

RUN wget --quiet -O /photon.zip $PHOTON_ZIP_URL_BASE/$PHOTON_BRANCH_TAG.zip && unzip -q -d /photon /photon.zip && mv /photon/photon-$PHOTON_BRANCH_TAG/src/ /photon/photon-$PHOTON_BRANCH_TAG/es/ /photon/photon-$PHOTON_BRANCH_TAG/website/ /photon/photon-$PHOTON_BRANCH_TAG/pom.xml /photon

RUN mvn -q -f /photon/pom.xml compile package -DskipTests=true

COPY import-address-postcode-polygons-preserve.style /nominatim/settings/

# Overwrite settings
COPY settings.php local.php /nominatim/build/settings/

COPY run.sh /

# Create symlink for photon-data
RUN cd /photon && ln -s /data/photon/latest photon-data

CMD /bin/bash /run.sh
