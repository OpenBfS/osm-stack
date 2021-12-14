FROM ubuntu:20.04

ARG PHOTON_VERSION
ARG PHOTON_ZIP_URL_BASE
ARG PHOTON_BRANCH_TAG

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y rsync openjdk-11-jdk maven openssh-client wget python3 unzip zip && \
    echo "A SSH public key will be copied into a Docker volume mounted at /ssh-authorized-keys in the next step. It will fail if you have not created this file yet! Please see the subsection \"SSH-Schlüssel\" in the chapter \"Geocoding\" in the setup guide for further details."

COPY id_root_ed25519 /ssh-private-keys/id_root_ed25519
RUN chmod 0600 /ssh-private-keys/id_root_ed25519

RUN rm -rf /root/.ssh && mkdir -p /ssh-private-keys/.ssh && chmod 755 /ssh-private-keys/.ssh && ln -s /ssh-private-keys/.ssh /root/.ssh

#RUN mkdir -p /photon && wget --quiet -O /photon/photon-$PHOTON_VERSION.jar https://github.com/komoot/photon/releases/download/$PHOTON_VERSION/photon-$PHOTON_VERSION.jar

RUN mkdir -p /photon/photon-$PHOTON_BRANCH_TAG

RUN wget --quiet -O /photon.zip $PHOTON_ZIP_URL_BASE/$PHOTON_BRANCH_TAG.zip && unzip -q -d /photon /photon.zip && mv /photon/photon-$PHOTON_BRANCH_TAG/src/ /photon/photon-$PHOTON_BRANCH_TAG/es/ /photon/photon-$PHOTON_BRANCH_TAG/website/ /photon/photon-$PHOTON_BRANCH_TAG/pom.xml /photon

RUN mvn -q -f /photon/pom.xml compile package -DskipTests=true && \
    zip -d /photon/target/photon-$PHOTON_VERSION.jar org/apache/logging/log4j/core/lookup/JndiLookup.class

COPY run_and_update.py /

CMD /usr/bin/python3 /run_and_update.py -d /photon-data/ -H $MASTER_HOSTNAME -u root -i /ssh-private-keys/id_root_ed25519 -p $MASTER_PORT -L /lock_directory.py -U /unlock_directory.py -r /data/photon -- /usr/bin/java -jar /photon/target/photon-$PHOTON_VERSION.jar -data-dir /photon-data/latest/
