#!/bin/bash

# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -e -x -v -u -o pipefail

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "${SCRIPT_DIR}/utilities/common.sh"

SERVING_PORT=${SERVING_PORT:-50080}

export COMFY_BASE_URL=${COMFY_BASE_URL:-""}

VENV_PATH="${PWD}/.venv" source "${PROJ_PATH}/scripts/utilities/ensure-venv.sh"

export PYTHONPATH=${PYTHONPATH:-}
export PYTHONPATH=${PYTHONPATH}:${PWD}
export PYTHONPATH=${PYTHONPATH}:${PWD}/src

pip install -r requirements.txt

# For each directory in editable-packages, install the package
for PACKAGE_DIRECTORY in $(ls -d editable-packages/*); do
  # Make it absolute
  PACKAGE_DIRECTORY=$(realpath $PACKAGE_DIRECTORY)
  pip install -e $PACKAGE_DIRECTORY
done
