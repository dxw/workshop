#!/bin/sh
set -xe

restore() {
  docker stop temp_mysql || true
  docker rm temp_mysql || true

  docker run --label=com.dxw.whippet=true --label=com.dxw.data=true --name=${1} -v /var/lib/mysql mysql /bin/true

  docker run -d --name=temp_mysql --volumes-from=${1} -e MYSQL_DATABASE=wordpress -e MYSQL_ROOT_PASSWORD=foobar mysql
  sleep 30
  docker run -i --rm --link=temp_mysql:mysql mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" "$MYSQL_ENV_MYSQL_DATABASE"' < backup/${1}.sql
}

DATA=`ls backup | cut -d. -f1`

docker stop whippet_mysql || true

for D in $DATA; do
  restore $D
done
