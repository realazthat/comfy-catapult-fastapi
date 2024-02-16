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

SERVING_PORT=${SERVING_PORT:-50080}

export COMFY_BASE_URL=${COMFY_BASE_URL:-""}

VENV_PATH="${PWD}/.venv" source "${SCRIPTS_PATH}/utilities/ensure-venv.sh"

export PYTHONPATH=${PYTHONPATH:-}
export PYTHONPATH=${PYTHONPATH}:${PWD}
export PYTHONPATH=${PYTHONPATH}:${PWD}/src

source "${SCRIPTS_PATH}/install-inside-repo.sh"

# if hostname -I > /dev/null 2>&1; then
#   # Get hostname for ubuntu
#   HOSTNAME=$(hostname -I | cut -d' ' -f1)
# else
#   # Get hostname for alpine
#   HOSTNAME=$(ip addr | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
# fi

HOSTNAME="0.0.0.0"

hypercorn src.main:app --bind ${HOSTNAME}:${SERVING_PORT} --reload


