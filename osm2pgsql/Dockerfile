FROM ubuntu:20.04

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y wget osm2pgsql wait-for-it python3 python3-pip postgresql-client-12

RUN pip3 install osmium

COPY openstreetmap-carto.lua /openstreetmap-carto.lua
COPY openstreetmap-carto.style /openstreetmap-carto.style

COPY loop.sh /loop.sh
COPY healthcheck.sh /healthcheck.sh

CMD /loop.sh

HEALTHCHECK CMD /healthcheck.sh
