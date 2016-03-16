FROM ubuntu:wily

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get dist-upgrade -y

##############################################################################
## Global configuration

RUN echo Europe/London > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN apt-get install --no-install-recommends -y sudo
RUN echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

# Fix "perl: warning: Setting locale failed."
RUN locale-gen en_US.UTF-8 en_GB.UTF-8

##############################################################################
## Install tools

RUN mkdir /src /home/core

RUN apt-get install --no-install-recommends -y build-essential pkg-config automake software-properties-common \
                                               locales man-db manpages less manpages-dev \
                                               openssh-client tmux zsh vim-nox \
                                               git mercurial bzr tig git-flow \
                                               python3 python3-pip python python-pip ruby ruby-dev php5-cli php5-mysql php5-gd nodejs npm perl perl-doc \
                                               curl wget bind9-host netcat whois ca-certificates dnsutils \
                                               silversearcher-ag sloccount zip unzip \
                                               libpcre3-dev liblzma-dev libxml2-dev libxslt1-dev libmysql++-dev libsqlite3-dev \
                                               optipng libtool nasm libjpeg-turbo-progs mysql-client nmap cloc ed ripmime oathtool cloc \
                                               libcurl4-openssl-dev libexpat1-dev gettext asciidoc xsltproc xmlto iproute2 iputils-ping xmlstarlet gnupg2 tree

# Fix bad defaults
RUN echo 'install: --no-rdoc --no-ri' > /etc/gemrc && \
    ln -s /usr/bin/nodejs /usr/local/bin/node && \
    echo 'error_reporting=E_ALL' > /etc/php5/cli/conf.d/99-dxw-errors.ini && \
    echo 'phar.readonly = Off' > /etc/php5/cli/conf.d/99-dxw-phar.ini && \
    echo '{"interactive":false}' > /home/core/.bowerrc

# Update git
RUN wget --quiet https://github.com/git/git/archive/v2.7.3.tar.gz -O /src/git.tar.gz && \
    tar -C /src -xzf /src/git.tar.gz && \
    make -C /src/git-* prefix=/usr/local NO_TCLTK=1 all doc install install-doc && \
    rm -rf /src/git.tar.gz /src/git-*

# Apparently pip2 from APT is broken
RUN wget --quiet https://bootstrap.pypa.io/get-pip.py -O /src/get-pip.py && \
    python /src/get-pip.py && \
    rm /src/get-pip.py

# Install things with package managers
RUN gem install bundler sass && \
    pip install --upgrade docker-compose && \
    npm install -g grunt-cli bower json standard standard-format

# Go
RUN wget --quiet https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz -O /src/go.tar.gz && \
    tar -C /usr/local -xzf /src/go.tar.gz && \
    rm /src/go.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

# Go tools
RUN GO15VENDOREXPERIMENT=1 GOPATH=/src/go go get github.com/dxw/git-env && \
    GO15VENDOREXPERIMENT=1 GOPATH=/src/go go get github.com/holizz/pw && \
    GO15VENDOREXPERIMENT=1 GOPATH=/src/go go get github.com/holizz/diceware && \
    GO15VENDOREXPERIMENT=1 GOPATH=/src/go go get github.com/drone/drone-cli/drone && \
    mv /src/go/bin/* /usr/local/bin/ && \
    rm -rf /src/go

# composer
RUN wget --quiet https://getcomposer.org/download/1.0.0-alpha10/composer.phar -O /usr/local/bin/composer && \
    chmod 755 /usr/local/bin/composer
ENV PATH=$PATH:/usr/local/lib/composer/vendor/bin:~/.composer/vendor/bin

# composer tools
RUN COMPOSER_HOME=/usr/local/lib/composer sh -c '\
    composer global require wp-cli/wp-cli && \
    composer global require fabpot/php-cs-fixer && \
    rm -rf $COMPOSER_HOME/cache\
    '

# Other tools
RUN git -C /src clone --quiet --recursive https://github.com/dxw/srdb.git && \
    ln -s /src/srdb/srdb /usr/local/bin/srdb
RUN git -C /src clone --quiet --recursive https://github.com/dxw/whippet && \
    cp -r /src/whippet /usr/local/share/whippet && \
    ln -s /usr/local/share/whippet/bin/whippet /usr/local/bin/whippet

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
