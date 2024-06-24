#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/basic.sh)

bash <(curl -SL $ROOT_URI/docker/install/install_apt_tpl.sh) \
  "debian" \
  "https://mirrors.tuna.tsinghua.edu.cn/docker-ce"
