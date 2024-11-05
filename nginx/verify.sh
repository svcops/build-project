#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086 disable=SC2028
if [ -z $ROOT_URI ]; then
  source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
else
  echo "\033[0;32mROOT_URI=$ROOT_URI\033[0m"
fi
# ROOT_URI=https://dev.kubectl.net

source <(curl -SL $ROOT_URI/nginx/verify_func.sh)

verify_nginx_configuration "$1" "$2"
