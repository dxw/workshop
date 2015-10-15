#!/bin/sh
set -xe

boot2docker up
`boot2docker shellinit`
docker ps || boot2docker ssh sudo /etc/init.d/docker restart
docker build --no-cache -t thedxw/workshop-base /workbench/src/git.dxw.net/workshop/base.git
docker build --no-cache -t workshop /workbench/workshop
