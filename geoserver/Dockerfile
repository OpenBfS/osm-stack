FROM oscarfonts/geoserver:2.17.0

RUN rm -R /var/local/geoserver/workspaces/*
COPY workspaces/ /var/local/geoserver/workspaces/

RUN apt-get update && apt-get install -y rsync wait-for-it && apt-get install -y --no-install-recommends postgresql-client
COPY id_root_ed25519 /ssh-private-keys/id_root_ed25519
COPY replicate.sh /replicate.sh
COPY run.sh /run.sh

ENTRYPOINT ["/bin/bash", "/run.sh"]

HEALTHCHECK --start-period=30s CMD curl http://localhost:8080/geoserver/
