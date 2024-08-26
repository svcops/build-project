#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086
# source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
ROOT_URI=https://code.kubectl.net/devops/build-project/raw/branch/main

bash <(curl -SL $ROOT_URI/docker/install/install_apt_tpl.sh) \
  "ubuntu" \
  "https://download.docker.com"
