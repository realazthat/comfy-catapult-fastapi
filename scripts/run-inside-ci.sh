#!/bin/bash
# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -e -x -v -u -o pipefail

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "${SCRIPT_DIR}/utilities/common.sh"

PROJECT_CLONE_PATH=${PROJECT_CLONE_PATH:-""}
ENV_VARS_FILE=${ENV_VARS_FILE:-""}

if [[ -z "${PROJECT_CLONE_PATH}" ]]; then
  echo -e "${RED}PROJECT_CLONE_PATH is not set${NC}"
  # trunk-ignore(shellcheck/SC2128)
  # trunk-ignore(shellcheck/SC2209)
  [[ $0 == "${BASH_SOURCE}" ]] && EXIT=exit || EXIT=return
  ${EXIT} 1
fi

# If PROJECT_CLONE_PATH has a trailing slash, remove it.
PROJECT_CLONE_PATH=$(echo "${PROJECT_CLONE_PATH}" | sed 's:/*$::')

if [[ -z "${ENV_VARS_FILE}" ]]; then
  echo -e "${RED}ENV_VARS_FILE is not set${NC}"
  # trunk-ignore(shellcheck/SC2128)
  # trunk-ignore(shellcheck/SC2209)
  [[ $0 == "${BASH_SOURCE}" ]] && EXIT=exit || EXIT=return
  ${EXIT} 1
fi

if [[ ! -f "${ENV_VARS_FILE}" ]]; then
  echo -e "${RED}${ENV_VARS_FILE} does not exist${NC}"
  # trunk-ignore(shellcheck/SC2128)
  # trunk-ignore(shellcheck/SC2209)
  [[ $0 == "${BASH_SOURCE}" ]] && EXIT=exit || EXIT=return
  ${EXIT} 1
fi

################################################################################
# Load environment variables
source "${ENV_VARS_FILE}"
################################################################################
# This is needed to use git on the directory since the owner is from another
# machine.
git config --global --add safe.directory "${PROJ_PATH}"
cd "${PROJ_PATH}"
mkdir -p "${PROJECT_CLONE_PATH}"
git checkout-index --all --prefix="${PROJECT_CLONE_PATH}/"
################################################################################
cd "${PROJECT_CLONE_PATH}"
ls -la /home/user/ci-project-export

VENV_PATH=.venv source "${PROJECT_CLONE_PATH}/scripts/utilities/ensure-venv.sh"

cat "${PROJECT_CLONE_PATH}/.python-version"
cat "${PROJECT_CLONE_PATH}/requirements.txt"
pip install -r requirements.txt

bash "${PROJECT_CLONE_PATH}/scripts/run-all-test-modules.sh"
bash "${PROJECT_CLONE_PATH}/scripts/run-smoke-test.sh"
################################################################################
