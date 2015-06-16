FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get dist-upgrade -y

##############################################################################
## Global configuration

RUN echo Europe/London > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN apt-get install --no-install-recommends -y sudo
RUN echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

##############################################################################
## Install tools

RUN mkdir /src

RUN apt-get install --no-install-recommends -y build-essential pkg-config automake \
                                               locales-all man-db manpages less manpages-dev \
                                               openssh-client tmux zsh vim-nox \
                                               git mercurial bzr tig git-flow \
                                               python3 python3-pip python python-pip ruby ruby-dev php5-cli php5-mysql php5-gd nodejs npm perl perl-doc \
                                               curl wget bind9-host netcat whois ca-certificates \
                                               silversearcher-ag sloccount zip unzip \
                                               libpcre3-dev liblzma-dev libxml2-dev libxslt1-dev libmysql++-dev libsqlite3-dev \
                                               optipng libtool nasm libjpeg-turbo-progs mysql-client nmap cloc ed ripmime oathtool cloc

# dpkg
RUN wget --quiet http://downloads.drone.io/master/drone.deb -O /src/drone.deb && \
    dpkg -i /src/drone.deb && \
    rm /src/drone.deb

# Fix bad defaults
RUN echo 'install: --no-rdoc --no-ri' > /etc/gemrc && \
    ln -s /usr/bin/nodejs /usr/local/bin/node &&\
    echo 'error_reporting=E_ALL' > /etc/php5/cli/conf.d/99-dxw-errors.ini &&\
    echo 'phar.readonly = Off' > /etc/php5/cli/conf.d/99-dxw-phar.ini

# Apparently pip2 from APT is broken
RUN wget --quiet https://bootstrap.pypa.io/get-pip.py -O /src/get-pip.py && \
    python /src/get-pip.py && \
    rm /src/get-pip.py

# Install things with package managers
RUN gem install bundler sass && \
    pip install --upgrade docker-compose && \
    npm install -g jshint grunt-cli bower json

# Go
RUN wget --quiet https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz -O /src/go.tar.gz && \
    tar -C /usr/local -xzf /src/go.tar.gz && \
    rm /src/go.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

# Go tools
RUN GOPATH=/src/go go get github.com/dxw/git-env && \
    GOPATH=/src/go go get github.com/holizz/pw && \
    GOPATH=/src/go go get github.com/holizz/diceware && \
    mv /src/go/bin/* /usr/local/bin/ && \
    rm -rf /src/go

# composer
RUN wget --quiet https://getcomposer.org/composer.phar -O /usr/local/bin/composer && \
    chmod 755 /usr/local/bin/composer
ENV COMPOSER_HOME=/usr/local/lib/composer
ENV PATH=$PATH:/usr/local/lib/composer/vendor/bin

# composer tools
RUN composer global require phpunit/phpunit && \
    composer global require wp-cli/wp-cli && \
    rm -rf $COMPOSER_HOME/cache

# Other tools
RUN git -C /src clone --quiet --recursive https://github.com/dxw/srdb.git && \
    ln -s /src/srdb/srdb /usr/local/bin/srdb
RUN git -C /src clone --quiet --recursive https://github.com/dxw/whippet && \
    cp -r /src/whippet /usr/local/share/whippet && \
    ln -s /usr/local/share/whippet/bin/whippet /usr/local/bin/whippet

##############################################################################
## Add user and dotfiles

RUN adduser --gecos '' --shell /bin/zsh --disabled-password core
RUN usermod -aG sudo core

RUN mkdir /home/core/.ssh
# Symlink known_hosts
RUN ln -s /workbench/home/.ssh/known_hosts /home/core/.ssh/known_hosts

RUN chown -R core:core /home/core

# Don't ask
RUN echo '{"interactive":false}' > /home/core/.bowerrc

##############################################################################
## Allow cloning private repos

RUN ssh-keyscan -t rsa git.dxw.net > /src/known_hosts && \
    /bin/echo -e '#!/bin/sh\nssh -i /home/core/.ssh/id_rsa -o "UserKnownHostsFile /src/known_hosts" $@' > /src/core-ssh.sh && \
    chmod 755 /src/core-ssh.sh

##############################################################################
## ONBUILD

# Dotfiles
ONBUILD COPY dotfiles/ /home/core/

# Copy in id_rsa
ONBUILD COPY keys/id_rsa /home/core/.ssh/id_rsa

# pluginscan
ONBUILD RUN GIT_SSH=/src/core-ssh.sh git -C /src clone --quiet git@git.dxw.net:tools/pluginscan2 pluginscan && \
    mkdir -p /usr/local/share/pluginscan && \
    cp -r /src/pluginscan/* /usr/local/share/pluginscan && \
    cd /usr/local/share/pluginscan && bundle install --path=vendor/bundle && \
    echo '#!/bin/sh' > /usr/local/bin/pluginscan && \
    echo 'BUNDLE_GEMFILE=/usr/local/share/pluginscan/Gemfile exec bundle exec /usr/local/share/pluginscan/bin/pluginscan' >> /usr/local/bin/pluginscan && \
    chmod 755 /usr/local/bin/pluginscan

# pupdate
ONBUILD RUN GIT_SSH=/src/core-ssh.sh git -C /src clone --quiet git@git.dxw.net:plugin-updater && \
    cp -r /src/plugin-updater /usr/local/share/pupdate && \
    /bin/echo -e '#!/bin/sh\nset -e\ncd /usr/local/share/pupdate/updating\n./update.sh $1 git@git.dxw.net:wordpress-plugins/$1\ncd -' > /usr/local/bin/pupdate && \
    chmod 755 /usr/local/bin/pupdate

# phar-install
ONBUILD RUN GIT_SSH=/src/core-ssh.sh git -C /src clone --quiet git@git.dxw.net:install-phar phar-install && \
    install /src/phar-install/bin/phar-install /usr/local/bin/phar-install

##############################################################################
## Startup

VOLUME /workbench
CMD ["tmux", "-u2"]