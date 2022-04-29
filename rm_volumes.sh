#!/bin/bash
source .env

for value in ${EXTERNAL_DOCKER_VOLUMES} ; do
  #WARNING: Only activate the following 2 lines in a development environment as it deletes all data in all volumes!
  #volpath=`docker volume inspect $value -f "{{ lower .Options.device }}"`
  #[ ${#volpath} -gt 20 ] && [ ${volpath:0:5} == "/data" ] && sudo rm -rf $volpath
  docker volume rm $value
done
