#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
echo -e "\033[0;32mROOT_URI=$ROOT_URI\033[0m"
# ROOT_URI=https://dev.kubectl.net

bash <(curl -sSL $ROOT_URI/docker/install/install_apt_tpl.sh) \
  "debian" \
  "https://mirrors.aliyun.com/docker-ce"
