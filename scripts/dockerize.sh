#!/bin/bash

# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -e -x -v -u -o pipefail

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "${SCRIPT_DIR}/utilities/common.sh"

IMAGE_NAME=comfy-catapult-fastapi-demo
IMAGE_TAG=${IMAGE_TAG:-""}

if [[ -z "${IMAGE_TAG}" ]]; then
  echo -e "${RED}IMAGE_TAG is not set${NC}"
  # trunk-ignore(shellcheck/SC2128)
  # trunk-ignore(shellcheck/SC2209)
  [[ $0 == "${BASH_SOURCE}" ]] && EXIT=exit || EXIT=return
  ${EXIT} 1
fi

CLEAN_CLONE_PATH="${PWD}/.dockertmp"
rm -rf "${CLEAN_CLONE_PATH}"
mkdir -p "${CLEAN_CLONE_PATH}"

PYTHON_VERSION=$(cat "${PROJ_PATH}/.python-version")

################################################################################
git checkout-index --all --prefix="${CLEAN_CLONE_PATH}/"
ls -la "${CLEAN_CLONE_PATH}"

EDITABLE_PKGS_DIRECTORY="${CLEAN_CLONE_PATH}/editable-packages"
mkdir -p "${CLEAN_CLONE_PATH}/editable-packages"

EDITABLE_PKGS_DIRECTORY="${EDITABLE_PKGS_DIRECTORY}" \
  bash "${SCRIPT_DIR}/extract_and_copy_editable_packages.sh"

cd "${CLEAN_CLONE_PATH}"
docker build \
  --build-arg PYTHON_VERSION="${PYTHON_VERSION}" \
  -t "${IMAGE_NAME}:${IMAGE_TAG}" .
