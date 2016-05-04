# workshop

This is a docker image that defines a development environment (vim, tmux, git, ssh, etc) which you can use in lieu of manually installing these things onto your machine. This means that if you get a new development machine you can theoretically just install Docker and immediately get back to work.

There are two main parts to our approach:

- The "workshop" is the docker image that contains your tools (vim, git, etc) - that's what this repo is for (you can of course create your own from scratch or using `FROM thedxw/workshop`)
- The "workbench" is where your code lives - in this project we assume that you have a directory called /workbench on the host machine

## How to

What you will need installed:

- docker-machine (OSX users should install [Docker Toolbox](https://www.docker.com/docker-toolbox))
- git

Note that this has only been tested with VirtualBox, but may work in other scenarios if you ignore the `init.sh` step.

Set up:

1. Set up a docker-machine instance (e.g. `docker-machine create --driver virtualbox default`)
1. Create your workbench and chown appropriately (e.g. `sudo mkdir /workbench && sudo chown tomdxw:staff /workbench`)
1. Clone the workshop image (e.g. `git clone https://github.com/dxw/workshop.git`)
1. You will need to get /workbench mounted inside the VM: `./tools/init.sh default` (replace `default` with the name of the docker-machine VM you created)

Run it:

1. `tools/run.sh default thedxw/workshop` (`default` being the docker-machine instance, `thedxw/workshop` being the name of the image you're using)

If everything worked, you should now be sitting inside a zsh session inside tmux.

### Configuring your workshop

To configure your workshop to how you like it, write a new Dockerfile based on the base workshop image:

    FROM thedxw/workshop

    # Switch WORKDIR/USER temporarily
    WORKDIR /
    USER root

    # do things here

    # Switch WORKDIR/USER back
    WORKDIR /workbench/src
    USER core

To see this in action: https://github.com/dxw/workshop-tomdxw

### Help - how do I load in my SSH keys?

There are a couple of approaches:

1. You can just mount your .ssh dir into ~: i.e. add `-v /Users/me/.ssh/:/home/core/.ssh/` to the `docker run` command
2. Write a new Dockerfile and add symlinks to a location within /workbench: `RUN ln -s /workbench/home/.ssh/id_rsa /home/core/.ssh/id_rsa && ln -s /workbench/home/.ssh/id_rsa.pub /home/core/.ssh/id_rsa.pub`
3. You could also use the COPY directive in a Dockerfile to put them in

### Port forwarding?

It's inconvenient to constantly be typing IPv4 addresses, so to permanently forward localhost:8000 to the VM:

    ./forward.sh 8000

### WordPress multisite

Multisite only works on port 80.

Prerequisites:

    brew install socat

Assuming you can access your site via http://mymachine.local:8000, run this script (and leave it running) and you'll be able to access it from http://mymachine.local.

    sudo ./port80.sh

### Having to press Ctrl-P twice is annoying

Set the detachKeys option in `.docker/config.json`:

    {
      "detachKeys": "ctrl-q,ctrl-u,ctrl-i,ctrl-t"
    }
