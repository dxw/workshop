#!/bin/sh
set -xe

backup() {
  docker stop temp_mysql || true
  docker rm temp_mysql || true
  docker run -d --name=temp_mysql --volumes-from=${1} -e MYSQL_DATABASE=wordpress -e MYSQL_ROOT_PASSWORD=foobar mysql
  docker run -ti --rm --link=temp_mysql:mysql mysql sh -c 'exec mysqldump -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" "$MYSQL_ENV_MYSQL_DATABASE" 2>/dev/null' > backup/${1}.sql
}

mkdir backup

docker stop whippet_mysql || true

DATA=`docker ps --no-trunc -a | grep whippet_mysql_data | awk '{print $13}'`

for D in $DATA; do
  backup $D
done
