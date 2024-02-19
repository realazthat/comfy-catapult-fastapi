#!/bin/bash

# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -e -x -v -u -o pipefail

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "${SCRIPT_DIR}/utilities/common.sh"

export COMFY_API_URL=${COMFY_API_URL:-""}
export IMAGE_TAG=${IMAGE_TAG:-""}
export REPOSITORY=${REPOSITORY:-""}

if [[ -z "${COMFY_API_URL}" ]]; then
  echo -e "${RED}COMFY_API_URL is not set${NC}"
  # trunk-ignore(shellcheck/SC2128)
  # trunk-ignore(shellcheck/SC2209)
  [[ $0 == "${BASH_SOURCE}" ]] && EXIT=exit || EXIT=return
  ${EXIT} 1
fi

if [[ -z "${IMAGE_TAG}" ]]; then
  echo -e "${RED}IMAGE_TAG is not set${NC}"
  # trunk-ignore(shellcheck/SC2128)
  # trunk-ignore(shellcheck/SC2209)
  [[ $0 == "${BASH_SOURCE}" ]] && EXIT=exit || EXIT=return
  ${EXIT} 1
fi

if [[ -z "${REPOSITORY}" ]]; then
  echo -e "${RED}REPOSITORY is not set${NC}"
  # trunk-ignore(shellcheck/SC2128)
  # trunk-ignore(shellcheck/SC2209)
  [[ $0 == "${BASH_SOURCE}" ]] && EXIT=exit || EXIT=return
  ${EXIT} 1
fi

SERVING_PORT=${DOCKER_SERVING_PORT:-50185}

IMAGE_NAME=comfy-catapult-fastapi-demo

docker run --rm -d \
  --name comfy-catapult-fastapi-demo \
  -p "${SERVING_PORT}:80" \
  -e "COMFY_API_URL=${COMFY_API_URL}" \
  "${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}"

echo -e "${GREEN}Serving comfy-catapult-fastapi-demo on http://host.docker.internal:${SERVING_PORT}/static/demo.html${NC}"

# Set trap to stop the container
trap "docker stop comfy-catapult-fastapi-demo" SIGINT SIGTERM

# Sleep forever
sleep infinity
