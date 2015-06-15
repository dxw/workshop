#!/bin/sh
set -xe

socat TCP-LISTEN:80,fork TCP:localhost:8000
