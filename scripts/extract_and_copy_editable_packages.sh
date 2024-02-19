#!/bin/bash

# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -e -x -v -u -o pipefail

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "${SCRIPT_DIR}/utilities/common.sh"

export EDITABLE_PKGS_DIRECTORY=${EDITABLE_PKGS_DIRECTORY:-""}
if [[ -z "${EDITABLE_PKGS_DIRECTORY}" ]]; then
  echo -e "${RED}EDITABLE_PKGS_DIRECTORY is not set${NC}"
  [[ $0 == "${BASH_SOURCE}" ]] && EXIT=exit || EXIT=return
  ${EXIT} 1
fi

VENV_PATH="${PWD}/.venv" source "${SCRIPTS_PATH}/utilities/ensure-venv.sh"

export PYTHONPATH=${PYTHONPATH:-}
export PYTHONPATH=${PYTHONPATH}:${PWD}
export PYTHONPATH=${PYTHONPATH}:${PWD}/src

EDITABLE_PKGS=$(python "${SCRIPTS_PATH}/extract_editable_packages.py")


time python ${SCRIPTS_PATH}/copy_editable_packages.py \
  --package_infos "${EDITABLE_PKGS}" \
  --output_dir "${EDITABLE_PKGS_DIRECTORY}"
