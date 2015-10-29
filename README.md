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
3. Clone this repo: `git clone git@git.dxw.net:workshop/base /workbench/workshop-base`
4. Go there: `cd /workbench/workshop-base/tools`
5. Clone my workshop image (you can write your own later): `git clone git@git.dxw.net:workshop/tomdxw /workbench/workshop`
6. Since my workshop image uses `WORKDIR /workbench/src` we need to create an extra directory: `mkdir /workbench/src`
7. Copy ssh keys, i.e.: `cp ~/.ssh/id_rsa /workbench/workshop/keys/`
8. Set up the docker-machine instance (this mounts /workbench inside the VM): `./init.sh`
9. Build the base image: `eval "$(docker-machine env default)" && docker build -t thedxw/workshop-base ..` (TODO: if/when we publish this repo on github we can get rid of this step)
10. If you like, forward some ports from the VM to the host machine to make it easier to work with your web apps, i.e.: `./forward.sh 8000 && ./forward.sh 1080`
11. Build the workshop image: `./build.sh`
12. Run the workshop: `./run.sh`
13. If everything went according to plan you are now sitting inside a tmux session in a docker container on a VM on your host machine

### WordPress multisite

Multisite only works on port 80.

Prerequisites:

    brew install socat

Assuming you can access your site via http://mymachine.local:8000, run this script (and leave it running) and you'll be able to access it from http://mymachine.local.

    sudo ./port80.sh
