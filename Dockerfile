FROM ubuntu:16.10

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    rm -r /var/lib/apt/lists/*

##############################################################################
## Global configuration

# Fix "perl: warning: Setting locale failed."
RUN locale-gen en_US.UTF-8 en_GB.UTF-8
ENV LC_ALL=en_GB.UTF-8

RUN echo Europe/London > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
# workaround: https://bugs.launchpad.net/ubuntu/+source/tzdata/+bug/1554806
RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime

RUN apt-get update && \
    apt-get install --no-install-recommends -y sudo && \
    rm -r /var/lib/apt/lists/*
RUN echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

##############################################################################
## Install tools

RUN mkdir /src /home/core

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        build-essential pkg-config automake software-properties-common \
        locales man-db manpages less manpages-dev \
        openssh-client tmux zsh vim-nox \
        git mercurial bzr tig git-flow \
        python3 python3-pip python3-setuptools python ruby ruby-dev nodejs npm perl perl-doc \
        php7.0-cli php7.0-gd php7.0-mbstring php7.0-mysql php7.0-xml php7.0-curl php-xdebug php-gmp \
        curl wget bind9-host netcat whois ca-certificates dnsutils net-tools \
        silversearcher-ag sloccount zip unzip \
        libpcre3-dev liblzma-dev libxml2-dev libxslt1-dev libmysql++-dev libsqlite3-dev \
        optipng libtool nasm libjpeg-turbo-progs mysql-client nmap cloc ed ripmime oathtool cloc \
        libcurl4-openssl-dev libexpat1-dev gettext asciidoc xsltproc xmlto iproute2 iputils-ping xmlstarlet gnupg2 tree jq && \
    rm -r /var/lib/apt/lists/*

# Lets Encrypt root certificate
RUN wget --quiet https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.pem -O /usr/local/share/ca-certificates/lets-encrypt-x1-cross-signed.crt && \
    wget --quiet https://letsencrypt.org/certs/lets-encrypt-x2-cross-signed.pem -O /usr/local/share/ca-certificates/lets-encrypt-x2-cross-signed.crt && \
    wget --quiet https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem -O /usr/local/share/ca-certificates/lets-encrypt-x3-cross-signed.crt && \
    wget --quiet https://letsencrypt.org/certs/lets-encrypt-x4-cross-signed.pem -O /usr/local/share/ca-certificates/lets-encrypt-x4-cross-signed.crt && \
    dpkg-reconfigure ca-certificates

# Fix bad defaults
RUN echo 'install: --no-rdoc --no-ri' > /etc/gemrc && \
    ln -s /usr/bin/nodejs /usr/local/bin/node && \
    echo 'error_reporting=E_ALL' > /etc/php/7.0/cli/conf.d/99-dxw-errors.ini && \
    echo 'phar.readonly=Off' > /etc/php/7.0/cli/conf.d/99-dxw-phar.ini && \
    echo 'xdebug.var_display_max_depth=99999' > /etc/php/7.0/cli/conf.d/99-dxw-fix-xdebug-var-dump.ini && \
    /bin/echo -e '[mail function]\nsendmail_path = /bin/false' > /etc/php/7.0/cli/conf.d/99-dxw-disable-mail.ini && \
    echo '{"analytics":false}' > /home/core/.bowerrc

# Update git
RUN wget --quiet https://github.com/git/git/archive/v2.11.0.tar.gz -O /src/git.tar.gz && \
    tar -C /src -xzf /src/git.tar.gz && \
    make -C /src/git-* prefix=/usr/local NO_TCLTK=1 all doc install install-doc && \
    make -C /src/git-*/contrib/subtree prefix=/usr/local NO_TCLTK=1 all doc install install-doc && \
    rm -rf /src/git.tar.gz /src/git-*

# Update npm
RUN npm install -g npm

# Install things with package managers
RUN gem install bundler sass && \
    pip3 install --upgrade docker-compose && \
    npm install -g grunt-cli bower json standard standard-format yo gulp

# Go
RUN wget --quiet https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz -O /src/go.tar.gz && \
    tar -C /usr/local -xzf /src/go.tar.gz && \
    rm /src/go.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

# Go tools
RUN GOPATH=/src/go go get github.com/dxw/git-env && \
    GOPATH=/src/go go get github.com/holizz/pw && \
    GOPATH=/src/go go get github.com/holizz/diceware && \
    GOPATH=/src/go go get github.com/src-d/beanstool && \
    mv /src/go/bin/* /usr/local/bin/ && \
    rm -rf /src/go

# composer
RUN wget --quiet https://getcomposer.org/download/1.4.2/composer.phar -O /usr/local/bin/composer && \
    chmod 755 /usr/local/bin/composer
ENV PATH=$PATH:/usr/local/lib/composer/vendor/bin:~/.composer/vendor/bin

# composer tools
RUN COMPOSER_HOME=/usr/local/lib/composer sh -c '\
    composer global require fabpot/php-cs-fixer && \
    rm -rf $COMPOSER_HOME/cache\
    '

# Heroku
RUN echo "deb http://toolbelt.heroku.com/ubuntu ./" > /etc/apt/sources.list.d/heroku.list
RUN wget -O- https://toolbelt.heroku.com/apt/release.key | apt-key add -
RUN apt-get update && \
    apt-get install -y heroku-toolbelt && \
    rm -r /var/lib/apt/lists/*

# Other tools
RUN git -C /src clone --quiet --recursive https://github.com/dxw/srdb.git && \
    ln -s /src/srdb/srdb /usr/local/bin/srdb
RUN git -C /src clone --quiet --recursive https://github.com/dxw/whippet && \
    cp -r /src/whippet /usr/local/share/whippet && \
    ln -s /usr/local/share/whippet/bin/whippet /usr/local/bin/whippet
RUN git -C /src clone --quiet https://github.com/dxw/wpc && \
    cp /src/wpc/bin/* /usr/local/bin

##############################################################################
## Add user

RUN adduser --gecos '' --shell /bin/zsh --disabled-password core
RUN usermod -aG sudo core

##############################################################################
## Startup

WORKDIR /workbench
USER core
VOLUME /workbench
CMD ["tmux", "-u2"]
