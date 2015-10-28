#!/bin/sh
set -xe

docker-machine start default
docker-machine ssh default 'echo -e "#!/bin/sh\nmkdir -p /workbench && mount -t vboxsf -o uid=1000,gid=1000 workbench /workbench" | sudo tee /var/lib/boot2docker/bootlocal.sh && sudo chmod 755 /var/lib/boot2docker/bootlocal.sh'
docker-machine stop default
VBoxManage sharedfolder add default --name workbench --hostpath /workbench
