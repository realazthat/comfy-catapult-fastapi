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

export COMFY_BASE_URL=${COMFY_BASE_URL:-""}

VENV_PATH="${PWD}/.venv" source "${PROJ_PATH}/scripts/utilities/ensure-venv.sh"

export PYTHONPATH=${PYTHONPATH:-}
export PYTHONPATH=${PYTHONPATH}:${PWD}
export PYTHONPATH=${PYTHONPATH}:${PWD}/src


export PORT=50082
EXISTING_PID=$(netstat -anp | grep $PORT | awk '{print $7}' | cut -d'/' -f1 || echo "")
# netstat -anp | grep $PORT | awk '{print $7}' | cut -d'/' -f1 | xargs kill -SIGINT || true

if [[ -n "${EXISTING_PID}" ]]; then
  echo -e "${RED}Killing existing process ${EXISTING_PID}${NC}"
  kill -SIGINT ${EXISTING_PID}
  wait ${EXISTING_PID} || true
fi

# hypercorn src.main:app --bind $(hostname -I | cut -d' ' -f1):$PORT --reload
export HOSTNAME=$(hostname -I | cut -d' ' -f1)


python -m src.main > >(tee /dev/stderr) 2>&1 &
FASTAPI_PID=$!

# trap "kill -SIGINT $FASTAPI_PID || true" EXIT
# trap "sleep 5 && kill -SIGKILL $FASTAPI_PID || true" EXIT

sleep 5

# {"job_id":"simple-workflow-2024-02-16t21-22-09-622z","positive_prompt":"A beautiful landscape overlooking a bustling fantasy city.","negative_prompt":"NSFW","ckpt_name":"sd_xl_base_1.0.safetensors","lora":{"name":"SDXLrender_v2.0.safetensors","strength":1},"hires":false,"seed":"0","cfg":"7","denoise":"1","steps":"30","width":"512","height":"768"}

PAYLOAD='{"job_id":"simple-workflow-2024-02-16t21-22-09-622z","positive_prompt":"A beautiful landscape overlooking a bustling fantasy city.","negative_prompt":"NSFW","ckpt_name":"sd_xl_base_1.0.safetensors","lora":{"name":"SDXLrender_v2.0.safetensors","strength":1},"hires":false,"seed":"0","cfg":"7","denoise":"1","steps":"30","width":"512","height":"768"}'
curl --fail -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "http://$HOSTNAME:$PORT/simple-workflow"

kill -SIGINT $FASTAPI_PID || true

wait $FASTAPI_PID || true
EXIT_STATUS=$?



echo -e "${GREEN}All examples ran successfully${NC}"
