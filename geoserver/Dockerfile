FROM oscarfonts/geoserver:2.16.2

RUN rm -R /var/local/geoserver/workspaces/*
COPY workspaces/ /var/local/geoserver/workspaces/

HEALTHCHECK --start-period=30s CMD curl http://localhost:8080/geoserver/
