#!/bin/sh
set -xe

test X$1 = X && echo 'Usage: ./forward.sh 1234' && exit 1

docker-machine stop default
VBoxManage modifyvm "default" --natpf1 "tcp$1,tcp,,$1,,$1"
