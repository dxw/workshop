#!/bin/sh
set -xe

MACHINE=${1}
if test X$MACHINE = X; then
  echo "Usage: ${0} machine-name"
  exit 1
fi

test X$2 = X && echo 'Usage: ./forward.sh 1234' && exit 1

docker-machine stop ${MACHINE}
VBoxManage modifyvm ${MACHINE} --natpf1 "tcp$1,tcp,,$1,,$1"
