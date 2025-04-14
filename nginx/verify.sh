#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086 disable=SC2028
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
echo -e "\033[0;32mROOT_URI=$ROOT_URI\033[0m" && export ROOT_URI=$ROOT_URI
# ROOT_URI=https://dev.kubectl.net

source <(curl -sSL $ROOT_URI/nginx/verify_func.sh)

verify_nginx_configuration "$1" "$2"
