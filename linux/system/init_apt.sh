#!/bin/bash
# debian 系列系统初始化
# shellcheck disable=SC1090
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)

log "system os" "os is $(bash <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/linux/system/detect_os.sh))"

apt-get update -y

DEBIAN_FRONTEND=noninteractive \
  apt-get \
  -o Dpkg::Options::=--force-confold \
  -o Dpkg::Options::=--force-confdef \
  -y --allow-downgrades --allow-remove-essential --allow-change-held-packages

apt install -y sudo vim git wget net-tools jq
