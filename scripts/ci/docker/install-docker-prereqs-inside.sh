# !/bin/bash
# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -e -x -v -u -o pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Ensure TARGET_USER is set
if [[ -z "${TARGET_USER:-}" ]]; then
    echo -e "${RED}TARGET_USER is not set${NC}"
    [[ $0 == "$BASH_SOURCE" ]] && EXIT=exit || EXIT=return
    $EXIT 1
fi

if [[ -z "${PYTHON_VERSION}" ]]; then
	echo -e "${RED}PYTHON_VERSION is not set${NC}"
	[[ $0 == "$BASH_SOURCE" ]] && EXIT=exit || EXIT=return
	$EXIT 1
fi

# Update and Upgrade the system
# apt-get update -y && apt-get upgrade -y
apk update && apk upgrade

# Install necessary basic tools
apk add --no-cache git curl wget build-base

apk add --no-cache tzdata
cp /usr/share/zoneinfo/UTC /etc/localtime
echo "UTC" > /etc/timezone
apk del tzdata

# Install dependencies for pyenv and Python build
apk add --no-cache make openssl-dev zlib-dev readline-dev sqlite-dev llvm \
  ncurses-dev xz-dev tk-dev libffi-dev bash bzip2-dev




################################################################################
YQ_VER=v4.40.5
YQ_BIN=yq_linux_amd64
YQ_URL="https://github.com/mikefarah/yq/releases/download/${YQ_VER}/${YQ_BIN}"
wget "$YQ_URL" -O /usr/bin/yq && chmod +x /usr/bin/yq
################################################################################

echo "export PYTHON_VERSION=\"${PYTHON_VERSION}\"" > /tmp/exported-env-vars

su - "${TARGET_USER}" -s /bin/bash <<'EOF'
# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -e -x -v -u -o pipefail

source /tmp/exported-env-vars

# Install pyenv
curl https://pyenv.run | bash


# Initialize Pyenv and Pyenv-Virtualenv and add them to .profile
echo 'if command -v pyenv 1>/dev/null 2>&1; then' >>~/.profile
echo '    eval "$(pyenv init --path)"' >>~/.profile
echo '    eval "$(pyenv virtualenv-init -)"' >>~/.profile
echo 'fi' >>~/.profile
################################################################################
# Pre-install required python version.

PYENV_ROOT="${HOME}/.pyenv"
PATH="${PYENV_ROOT}/bin:${PATH}"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

pyenv install --skip-existing "${PYTHON_VERSION}"
################################################################################
EOF

# Clean up APT when done.
rm -rf /var/cache/apk/*

echo "Prerequisites installed."
