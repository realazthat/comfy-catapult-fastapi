#!/bin/bash

# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -e -x -v -u -o pipefail

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "${SCRIPT_DIR}/utilities/common.sh"

export COMFY_API_URL=${COMFY_API_URL:-""}

if [[ -z "${COMFY_API_URL}" ]]; then
  echo -e "${RED}COMFY_API_URL is not set${NC}"
  # trunk-ignore(shellcheck/SC2128)
  # trunk-ignore(shellcheck/SC2209)
  [[ $0 == "${BASH_SOURCE}" ]] && EXIT=exit || EXIT=return
  ${EXIT} 1
fi

SERVING_PORT=${DOCKER_SERVING_PORT:-50185}

IMAGE_NAME=comfy-catapult-simple-workflow-example
IMAGE_TAG=2024-02-01
REPOSITORY=realazthat

docker run --rm -it \
  --name simple-workflow-example \
  -p ${SERVING_PORT}:80 \
  -e COMFY_API_URL=${COMFY_API_URL} \
  $REPOSITORY/$IMAGE_NAME:$IMAGE_TAG
