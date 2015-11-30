# workshop

The idea is that if your development environment is all reproducible and contained then if you need a new computer you don't need to spend a day installing everything.

To explain the concept breifly:

- A "workshop" is your development environment - where you have vim, git, and other things that you need on all projects
- A "workbench" is where all your code lives - here we use /workbench on the host machine

## How to

These instructions assume we're running on OSX. But these instructions will probably work on any host that supports docker-machine.

What you will need installed:

- docker-machine (OSX users should install [Docker Toolbox](https://www.docker.com/docker-toolbox))
- git

What you will need to do:

1. Make sure there's a docker-machine instance named default that uses VirtualBox (you can use an existing one but note that it will be modified): `docker-machine create --driver virtualbox default`
2. Create your workbench, and chown it appropriately: `sudo mkdir /workbench && sudo chown tomdxw:staff /workbench`
3. Clone this repo: `git clone git@git.dxw.net:workshop/base workshop-base && cd workshop-base`
4. Go to the tools dir: `cd workshop-base/tools`
5. Set up the docker-machine instance (this mounts /workbench inside the VM): `./init.sh`
6. Build the base image: `eval "$(docker-machine env default)" && docker build -t thedxw/workshop-base ..` (TODO: if/when we publish this repo on github we can get rid of this step)
7. On the line in `run.sh` that starts "exec docker run", replace the final "workshop" with "thedxw/workshop-base"
8. Run the workshop: `./run.sh`
9. If everything went according to plan you are now sitting inside a tmux session in a docker container on a VM on your host machine

### Configuring your workshop

To configure your workshop to how you like it, write a new Dockerfile based on the base workshop image:

    FROM thedxw/workshop-base

    # Switch WORKDIR/USER temporarily
    WORKDIR /
    USER root

    # do things here

    # Switch WORKDIR/USER back
    WORKDIR /workbench/src
    USER core

To see this in action: git@git.dxw.net:workshop/tomdxw

### Help - how do I load in my SSH keys?

There are a couple of approaches:

1. You can just mount your .ssh dir into ~: i.e. add `-v /Users/me/.ssh/:/home/core/.ssh/` to the `docker run` command
2. Write a new Dockerfile and add symlinks to a location within /workbench: `RUN ln -s /workbench/home/.ssh/id_rsa /home/core/.ssh/id_rsa && ln -s /workbench/home/.ssh/id_rsa.pub /home/core/.ssh/id_rsa.pub`
3. You could also use the COPY directive in a Dockerfile to put them in

### Port forwarding?

It's inconvenient to constantly be typing IPv4 addresses, so to forward localhost:8000 to the VM:

    ./forward.sh 8000

### WordPress multisite

Multisite only works on port 80.

Prerequisites:

    brew install socat

Assuming you can access your site via http://mymachine.local:8000, run this script (and leave it running) and you'll be able to access it from http://mymachine.local.

    sudo ./port80.sh
