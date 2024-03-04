#!/bin/bash
# debian 系列系统初始化
# shellcheck disable=SC1090
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)

log "system os" "os is $(bash <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/linux/system/detect_os.sh))"

apt update -y

export DEBIAN_FRONTEND=noninteractive
apt-o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef -y --allow-downgrades --allow-remove-essential --allow-change-held-packages

apt install -y sudo vim git wget net-tools jq
