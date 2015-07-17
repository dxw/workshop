#!/bin/sh
# set -xe

docker ps -a | grep -v whippet_mysql_data | awk '{print $1}' | xargs docker rm
docker images | grep '^<none>' | awk '{print $3}' | xargs docker rmi
