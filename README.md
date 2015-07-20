# workshop

The idea is that if your development environment is all reproducible and contained then if you need a new computer you don't need to spend a day installing everything.

So, to explain it breifly:

* A "workshop" is your development environment - where you have vim, git, and other things that you need on all projects
* A "workbench" is where all your code lives

## How to

1. mkdir /workbench on the host machine - that will be where your code and stuff lives
2. Install boot2docker
3. git clone git@git.dxw.net:workshop/base /workbench/workshop-base
4. Ensure your workshop is checked out at /workbench/workshop - you can use mine if you don't already have one - git clone git@git.dxw.net:workshop/tomdxw /workbench/workshop
5. Copy private bits. For example: cp ~/.ssh/id_rsa /workbench/workshop/keys/
6. cd /workbench/workshop-base
7. docker build -t thedxw/workshop-base .
8. cd tools
9. Set up the boot2docker VM: ./init.sh
10. Forward some ports from the VM to the host machine: ./forward.sh 8000 && ./forward.sh 1080 (for example)
11. Build your workshop: ./build.sh
12. Run your workshop: ./run.sh
13. If everything went according to plan you are now sitting inside a tmux session in a docker container on a VM on your host machine

### WordPress multisite

Prerequisites:

    brew install socat

Assuming you can access your site via http://mymachine.local:8000, run this script (and leave it running) and you'll be able to access it from http://mymachine.local.

    sudo ./port80.sh

## Extra tools

In tools/internal there are some tools designed to be used from within the workshop container. (i.e. they don't have "boot2docker shellinit" in them.)

clean.sh - deletes unneeded images and containers. (check it does what you want first - it may delete data containers you don't want to delete)
