#!/bin/bash
# shellcheck disable=SC1090,SC2086,SC2155,SC2128,SC2028,SC2164,SC2162
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh) && export ROOT_URI=$ROOT_URI
# ROOT_URI=https://dev.kubectl.net

source <(curl -sSL $ROOT_URI/func/log.sh)
