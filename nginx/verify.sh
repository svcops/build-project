#!/bin/bash
# shellcheck disable=SC1090
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/nginx/verify_func.sh)

function verify() {
  verify_nginx_configuration "$1" "$2"
}

verify "$1" "$2"
