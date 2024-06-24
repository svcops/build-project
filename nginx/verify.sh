#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/basic.sh)

source <(curl -sSL $ROOT_URI/nginx/verify_func.sh)

verify_nginx_configuration "$1" "$2"
