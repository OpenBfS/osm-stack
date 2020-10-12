FROM ubuntu:20.04

ARG VROOM_ZIP_URL_BASE=https://github.com/VROOM-Project/vroom/archive
ARG VROOM_BRANCH_TAG
ARG VROOM_BRANCH_TAG_IN_ZIP
ARG VROOM_EXPRESS_ZIP_URL_BASE=https://github.com/VROOM-Project/vroom-express/archive
ARG VROOM_EXPRESS_BRANCH_TAG
ARG VROOM_EXPRESS_BRANCH_TAG_IN_ZIP
ARG VROOM_EXPRESS_CONFIG

ARG DEBIAN_FRONTEND=noninteractive

# install xinetd to make it possible to add check_mk to the Docker container
# procps (to be precise: the 'pgrep' binary) is required by the postinst script of check-mk-agent
COPY thirdparty/check-mk-agent_1.5.0p24-1_all.deb /tmp/check-mk-agent.deb
RUN apt-get -qq update && apt-get -qq upgrade -f && apt-get -qq -y install xinetd procps
RUN dpkg -i /tmp/check-mk-agent.deb && rm /tmp/check-mk-agent.deb

# Install GPG key for NodeJS, install NodeJS and VROOM dependencies
RUN apt-get -qq -y install curl wget gnupg unzip git build-essential g++ libssl-dev libasio-dev pkg-config
RUN apt-get -qq -y install nodejs npm

# Install VROOM-Express
RUN mkdir /vroom-express && \
    cd /vroom-express && \
    wget --quiet -O /vroom-express.zip $VROOM_EXPRESS_ZIP_URL_BASE/$VROOM_EXPRESS_BRANCH_TAG.zip && \
    unzip -q -d /vroom-express /vroom-express.zip && \
    mv /vroom-express/vroom-express-$VROOM_EXPRESS_BRANCH_TAG_IN_ZIP/* /vroom-express

# Patch VROOM-Express
COPY patches/log-to-stdout.patch /

RUN patch /vroom-express/src/index.js /log-to-stdout.patch && \
    rm /log-to-stdout.patch && \
    rm /vroom-express.zip

# Overwrite VROOM-Express configuration
COPY $VROOM_EXPRESS_CONFIG /vroom-express/config.yml

# Run npm install
RUN cd /vroom-express && \
    npm config set loglevel error && \
    npm install

# Install VROOM
RUN mkdir /vroom && \
    wget --quiet -O /vroom.zip $VROOM_ZIP_URL_BASE/$VROOM_BRANCH_TAG.zip && \
    unzip -q -d /vroom /vroom.zip && \
    mv /vroom/vroom-$VROOM_BRANCH_TAG_IN_ZIP/* /vroom && \
    rm /vroom.zip && \
    cd vroom && \
    make -C /vroom/src

# Prepare directories
RUN mkdir -p /var/lib/vroom-express/tmp

COPY docker-entrypoint.sh /

CMD /bin/bash /docker-entrypoint.sh
