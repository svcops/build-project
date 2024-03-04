#!/bin/bash
# debian 系列系统初始化
# shellcheck disable=SC1090
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)

apt install -y curl

log "system os" "os is $(bash <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/linux/system/detect_os.sh))"

apt update -y
apt upgrade -y

apt install -y sudo vim git wget net-tools jq
