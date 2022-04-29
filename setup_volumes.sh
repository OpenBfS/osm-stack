#!/bin/bash
source .env

for value in ${EXTERNAL_DOCKER_VOLUMES} ; do
  mkdir -p ${EXTERNAL_VOLUME_BASE_DIR}/$value
  docker volume create --driver local --opt type=none --opt device=${EXTERNAL_VOLUME_BASE_DIR}/$value --opt o=bind --name=$value
done
