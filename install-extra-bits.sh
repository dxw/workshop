#!/bin/sh
set -xe

rm -rf /workbench/local

SRC=/workbench/local/src
SHARE=/workbench/local/share
BIN=/workbench/local/bin
LIB=/workbench/local/lib
mkdir -p ${SRC} ${SHARE} ${BIN} ${LIB}

# pluginscan
git -C ${SRC} clone --quiet git@git.govpress.com:dxw/pluginscan.git pluginscan && \
  sh -c "cd ${SRC}/pluginscan && gem build pluginscan.gemspec" && \
  gem install --install-dir=${LIB}/rubygems ${SRC}/pluginscan/pluginscan-0.9.0.gem
  echo '#!/bin/sh' > ${BIN}/pluginscan && \
  echo 'GEM_PATH=${GEM_PATH}:'${LIB}'/rubygems exec '${LIB}'/rubygems/bin/pluginscan ${@}' >> ${BIN}/pluginscan && \
  chmod 755 ${BIN}/pluginscan

# pupdate
git -C ${SRC} clone --quiet git@git.dxw.net:plugin-updater && \
  cp -r ${SRC}/plugin-updater ${SHARE}/pupdate && \
  /bin/echo -e '#!/bin/sh\nset -e\ncd '${SHARE}'/pupdate/updating\n./update.sh $1 git@git.dxw.net:wordpress-plugins/$1\ncd -' > ${BIN}/pupdate && \
  chmod 755 ${BIN}/pupdate
