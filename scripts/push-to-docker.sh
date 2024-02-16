#!/bin/bash

# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -e -x -v -u -o pipefail

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "${SCRIPT_DIR}/utilities/common.sh"

IMAGE_NAME=comfy-catapult-simple-workflow-example
IMAGE_TAG=2024-02-01


docker tag $IMAGE_NAME:$IMAGE_TAG realazthat/$IMAGE_NAME:$IMAGE_TAG

docker push realazthat/$IMAGE_NAME:$IMAGE_TAG

