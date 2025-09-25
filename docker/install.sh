#!/bin/bash
# shellcheck disable=SC1090
[ -z "$ROOT_URI" ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
bash <(curl -sSL "$ROOT_URI/docker/install/i.sh") "$1"
