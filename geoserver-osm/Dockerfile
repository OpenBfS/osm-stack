ARG GEOSERVER_VERSION
FROM terrestris/geoserver:${GEOSERVER_VERSION}

ARG GEOSERVER_CONTEXT
ENV GEOSERVER_CONTEXT=${GEOSERVER_CONTEXT}

# add adjusted server.xml
# includes maxHttpHeaderSize
COPY server.xml $CATALINA_HOME/conf/

RUN apt-get update && apt-get install -y rsync wait-for-it && apt-get install -y --no-install-recommends postgresql-client
COPY id_root_ed25519 /ssh-private-keys/id_root_ed25519
RUN chmod 0600 /ssh-private-keys/id_root_ed25519
COPY replicate.sh /opt/replicate.sh

COPY start_custom.sh /opt/start_custom.sh
ENTRYPOINT ["/bin/sh", "/opt/start_custom.sh"]

HEALTHCHECK --start-period=30s CMD curl http://localhost:8080/${GEOSERVER_CONTEXT}/
