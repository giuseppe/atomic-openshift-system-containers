#!/bin/sh
export SRC_REGISTRY=docker.io
export SRC_PREFIX=openshift
export MASTER_IMAGE=origin
export SRC_TAG=${SRC_TAG-v1.3.1}
export DEST_TAG=${DEST_TAG-v1.3.1}

./generate_images.sh $@
