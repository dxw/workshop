#!/bin/sh
set -xe

test X$1 = X && echo 'Usage: ./forward.sh 1234' && exit 1

boot2docker suspend
VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp$1,tcp,,$1,,$1"
