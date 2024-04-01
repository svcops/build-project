#!/bin/bash
# shellcheck disable=SC1090
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/nginx/verify_func.sh)

verify_nginx_configuration "$1" "$2"
