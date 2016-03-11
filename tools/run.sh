#!/bin/sh
set -xe

MACHINE=${1}
IMAGE=${2}
if test X${MACHINE} = X || test X${IMAGE} = X; then
  echo "Usage: ${0} machine-name image-name"
  echo "i.e. ${0} default thedxw/workshop"
  exit 1
fi

docker-machine start ${MACHINE} || true
eval "$(docker-machine env ${MACHINE})"

if test X`docker inspect --format='{{.State.Running}}' workshop` = Xtrue; then
  exec docker attach workshop
else
  docker rm workshop || true
  exec docker run -ti --rm --name workshop --hostname workshop -e "DOCKER_HOST=${DOCKER_HOST}" -e "DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY}" -e DOCKER_CERT_PATH=/docker-cert -v "${DOCKER_CERT_PATH}:/docker-cert:ro" -v /usr/local/bin/docker:/usr/bin/docker:ro -v /workbench:/workbench ${IMAGE}
fi
