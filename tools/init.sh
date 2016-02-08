#!/bin/sh
set -xe

MACHINE=${1}
if test X$MACHINE = X; then
  echo "Usage: ${0} machine-name"
  exit 1
fi

docker-machine start ${MACHINE} || true
docker-machine ssh ${MACHINE} 'echo -e "#!/bin/sh\nmkdir -p /workbench && mount -t vboxsf -o uid=1000,gid=1000 workbench /workbench" | sudo tee /var/lib/boot2docker/bootlocal.sh && sudo chmod 755 /var/lib/boot2docker/bootlocal.sh'
docker-machine stop ${MACHINE}
VBoxManage sharedfolder add ${MACHINE} --name workbench --hostpath /workbench
