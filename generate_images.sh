#!/bin/bash -x
set -euo pipefail

SRC_REGISTRY=registry.access.redhat.com
SRC_PREFIX=openshift3
DEST_PREFIX=127.0.0.1:5000

for i in ose node openvswitch; do
    docker pull $SRC_REGISTRY/$SRC_PREFIX/$i
done

NAME_CONTAINER=builder-$$

clean () {
    docker ps | grep -q $NAME_CONTAINER && docker rm -f $NAME_CONTAINER 
}

trap clean EXIT

for i in ose node openvswitch; do
    docker run -d --name $NAME_CONTAINER $SRC_REGISTRY/$SRC_PREFIX/$i
    mkdir -p rootfs-$i/exports
    docker export $NAME_CONTAINER | tar -C rootfs-$i -xf -
    cp $i/config.json rootfs-$i/exports
    tar -C rootfs-$i --to-stdout -c . | docker import - $DEST_PREFIX/$i
    rm -rf rootfs-$i
    docker rm -f $NAME_CONTAINER 
done

for i in ose node openvswitch; do
    yes | docker push $DEST_PREFIX/$i
done
