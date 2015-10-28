#!/bin/sh
set -xe

docker-machine start default
eval "$(docker-machine env default)"

if test X`docker inspect --format='{{.State.Running}}' workshop` = Xtrue; then
  exec docker attach workshop
else
  docker rm workshop || true
  exec docker run -ti --rm --name workshop --hostname workshop -e "DOCKER_HOST=$DOCKER_HOST" -e "DOCKER_TLS_VERIFY=$DOCKER_TLS_VERIFY" -e DOCKER_CERT_PATH=/docker-cert -v "$DOCKER_CERT_PATH:/docker-cert:ro" -v /usr/local/bin/docker:/usr/bin/docker:ro -v /workbench:/workbench workshop
fi
