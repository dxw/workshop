#!/bin/sh
set -xe

boot2docker up
`boot2docker shellinit`
docker build --no-cache -t workshop /workbench/workshop
