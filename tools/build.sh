#!/bin/sh
set -xe

docker-machine start default
eval "$(docker-machine env default)"

docker build --no-cache -t thedxw/workshop-base /workbench/src/git.dxw.net/workshop/base.git
docker build --no-cache -t workshop /workbench/workshop
