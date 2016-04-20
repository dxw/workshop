# workshop

This is a docker image that defines a development environment (vim, tmux, git, ssh, etc) which you can use in lieu of manually installing these things onto your machine. This means that if you get a new development machine you can theoretically just install Docker and immediately get back to work.

There are two main parts to our approach:

- The "workshop" is the docker image that contains your tools (vim, git, etc) - that's what this repo is for (you can of course create your own from scratch or using `FROM thedxw/workshop`)
- The "workbench" is where your code lives - in this project we assume that you have a directory called /workbench on the host machine

## How to

What you will need installed:

- [Docker for Mac](https://docs.docker.com/docker-for-mac/)
- [git](https://git-scm.com/)

Set up:

1. Make sure Docker.app is running
1. Create your workbench and chown appropriately (e.g. `sudo mkdir /workbench && sudo chown tomdxw:staff /workbench`)
1. In Docker for Mac's preferences, add /workbench as a shared folder
1. Clone the workshop image: `cd /workbench && git clone https://github.com/dxw/workshop.git`

Run it:

1. `/workbench/workshop/tools/run.sh thedxw/workshop` (you can use another image instead of `thedxw/workshop`, such as `thedxw/workshop-tomdxw`)

If everything worked, you should now be sitting inside a zsh session inside tmux inside Ubuntu inside Docker inside a custom Linux distro inside xhyve inside macOS.

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

Here's an example: https://github.com/dxw/workshop-tomdxw

### Help - how do I load in my SSH keys?

There are a few approaches:

1. (Recommended) Write a new Dockerfile and add symlinks to a location within /workbench: `RUN ln -s /workbench/home/.ssh/id_rsa /home/core/.ssh/id_rsa && ln -s /workbench/home/.ssh/id_rsa.pub /home/core/.ssh/id_rsa.pub`
2. You can just mount your .ssh dir into ~: i.e. add `-v /Users/me/.ssh/:/home/core/.ssh/` to the `docker run` command
3. You could also use the COPY directive in a Dockerfile to put them in

### Having to press Ctrl-P twice is annoying

Set the detachKeys option in `.docker/config.json`:

    {
      "detachKeys": "ctrl-q,ctrl-u,ctrl-i,ctrl-t"
    }
