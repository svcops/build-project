#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086
if [ -z $ROOT_URI ]; then
  source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
else
  echo -e "\033[0;32mROOT_URI=$ROOT_URI\033[0m"
fi
# ROOT_URI=https://dev.kubectl.net

bash <(curl -SL $ROOT_URI/docker/install/install_apt_tpl.sh) \
  "ubuntu" \
  "https://download.docker.com"
