#!/bin/sh
set -xe

boot2docker up
`boot2docker shellinit`
docker rm workshop || docker attach workshop ||
docker run -ti --name workshop -h workshop -e "DOCKER_HOST=$DOCKER_HOST" -e "DOCKER_TLS_VERIFY=$DOCKER_TLS_VERIFY" -e DOCKER_CERT_PATH=/boot2docker-cert -v "$DOCKER_CERT_PATH:/boot2docker-cert:ro" -v /usr/local/bin/docker:/usr/bin/docker:ro -v /workbench:/workbench workshop
