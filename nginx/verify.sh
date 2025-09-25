#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086 disable=SC2028
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
# ROOT_URI=https://dev.kubectl.net

source <(curl -sSL $ROOT_URI/nginx/verify_func.sh)

verify_nginx_configuration "$1" "$2"
