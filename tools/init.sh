#!/bin/sh
set -xe

boot2docker init
boot2docker up
boot2docker ssh 'echo -e "#!/bin/sh\nmkdir -p /workbench && mount -t vboxsf -o uid=1000,gid=1000 workbench /workbench" | sudo tee /var/lib/boot2docker/bootlocal.sh && sudo chmod 755 /var/lib/boot2docker/bootlocal.sh'
boot2docker halt
VBoxManage sharedfolder add boot2docker-vm --name workbench --hostpath /workbench
