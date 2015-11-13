#!/bin/sh
set -xe

rm -rf /workbench/local

SRC=/workbench/local/src
SHARE=/workbench/local/share
BIN=/workbench/local/bin
mkdir -p ${SRC} ${SHARE} ${BIN}

# pluginscan
git -C ${SRC} clone --quiet git@git.dxw.net:tools/pluginscan2 pluginscan && \
  mkdir -p ${SHARE}/pluginscan && \
  cp -r ${SRC}/pluginscan/* ${SHARE}/pluginscan && \
  cd ${SHARE}/pluginscan && bundle install --path=vendor/bundle && \
  echo '#!/bin/sh' > ${BIN}/pluginscan && \
  echo 'BUNDLE_GEMFILE='${SHARE}'/pluginscan/Gemfile exec bundle exec '${SHARE}'/pluginscan/bin/pluginscan $@' >> ${BIN}/pluginscan && \
  chmod 755 ${BIN}/pluginscan

# pupdate
git -C ${SRC} clone --quiet git@git.dxw.net:plugin-updater && \
  cp -r ${SRC}/plugin-updater ${SHARE}/pupdate && \
  /bin/echo -e '#!/bin/sh\nset -e\ncd '${SHARE}'/pupdate/updating\n./update.sh $1 git@git.dxw.net:wordpress-plugins/$1\ncd -' > ${BIN}/pupdate && \
  chmod 755 ${BIN}/pupdate
