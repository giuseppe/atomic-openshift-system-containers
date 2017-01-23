#!/bin/bash -x
set -euo pipefail

SRC_REGISTRY=${SRC_REGISTRY-registry.access.redhat.com}
SRC_PREFIX=openshift3

SRC_TAG=${SRC_TAG-v3.3.0.26}
DEST_TAG=${DEST_TAG-v3.3.0.26}
NO_PULL=${NO_PULL-}

if test $# -eq 0; then
    #docker run -d -p 5000:5000 --restart=always --name registry   -v /etc/registry-certs:/certs \
    #-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/server.crt -e REGISTRY_HTTP_TLS_KEY=/certs/server.key \
    #-v /var/lib/storage/registry/:/var/lib/registry:Z \registry:2
    echo "Please specify a destination registry"
    exit 1
fi

DEST_PREFIX=$1/$SRC_PREFIX

if test x$NO_PULL != x1; then
    for i in ose node openvswitch; do
        docker pull $SRC_REGISTRY/$SRC_PREFIX/$i:$SRC_TAG
    done
fi

NAME_CONTAINER=builder-$$

clean () {
    rm -rf _build
}

trap clean EXIT

for i in ose node openvswitch; do
    rm -rf _build
    mkdir _build
    cp $i/* _build
    sed -e "s|\$ORIGIN|$SRC_REGISTRY/$SRC_PREFIX/$i:$SRC_TAG|g" < _build/Dockerfile.in > _build/Dockerfile
    cat _build/Dockerfile
    docker build -t $DEST_PREFIX/$i:$DEST_TAG _build
done

set +euo pipefail

for i in ose node openvswitch; do
    yes | docker push $DEST_PREFIX/$i:$DEST_TAG
done
