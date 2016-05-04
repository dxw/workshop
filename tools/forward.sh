#!/bin/sh
set -xe

MACHINE=${1}
if test X$MACHINE = X; then
  echo "Usage: ${0} machine-name port"
  exit 1
fi

test X$2 = X && echo 'Usage: ./forward.sh 1234' && exit 1

docker-machine stop ${MACHINE} || true
VBoxManage modifyvm ${MACHINE} --natpf1 "tcp$2,tcp,,$2,,$2"
