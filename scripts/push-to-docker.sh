#!/bin/bash

# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -e -x -v -u -o pipefail

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "${SCRIPT_DIR}/utilities/common.sh"

IMAGE_NAME=comfy-catapult-fastapi-demo
IMAGE_TAG=${IMAGE_TAG:-""}
REPOSITORY=${REPOSITORY:-""}

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

docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}"

docker push "${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}"
# Also set the remote image to latest tag
docker tag "${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}" "${REPOSITORY}/${IMAGE_NAME}:latest"
# Push the latest tag
docker push "${REPOSITORY}/${IMAGE_NAME}:latest"
