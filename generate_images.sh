#!/bin/bash -x
set -euo pipefail

SRC_REGISTRY=${SRC_REGISTRY-registry.access.redhat.com}
SRC_PREFIX=openshift3

SRC_TAG=${SRC_TAG-v3.3.0.26}
DEST_TAG=${DEST_TAG-v3.3.0.26}

if test $# -eq 0; then
    #docker run -d -p 5000:5000 --restart=always --name registry   -v /etc/registry-certs:/certs \
    #-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/server.crt -e REGISTRY_HTTP_TLS_KEY=/certs/server.key \
    #-v /var/lib/storage/registry/:/var/lib/registry:Z \registry:2
    echo "Please specify a destination registry"
    exit 1
fi

DEST_PREFIX=$1/$SRC_PREFIX

for i in ose node openvswitch; do
    docker pull $SRC_REGISTRY/$SRC_PREFIX/$i:$SRC_TAG
done

NAME_CONTAINER=builder-$$

clean () {
    docker ps | grep -q $NAME_CONTAINER && docker rm -f $NAME_CONTAINER 
}

trap clean EXIT

for i in ose node openvswitch; do
    docker run -d --name $NAME_CONTAINER $SRC_REGISTRY/$SRC_PREFIX/$i:$SRC_TAG
    mkdir -p rootfs-$i/exports
    docker export $NAME_CONTAINER | tar -C rootfs-$i -xf -
    cp $i/config.json rootfs-$i/exports
    tar -C rootfs-$i --to-stdout -c . | docker import -c "ENTRYPOINT /usr/bin/openshift" - $DEST_PREFIX/$i:$DEST_TAG
    rm -rf rootfs-$i
    docker rm -f $NAME_CONTAINER
done

set +euo pipefail

for i in ose node openvswitch; do
    yes | docker push $DEST_PREFIX/$i:$DEST_TAG
done
