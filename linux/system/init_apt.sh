#!/bin/bash
# debian 系列系统初始化
# shellcheck disable=SC1090
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)

log "system os" "os is $(bash <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/linux/system/detect_os.sh))"

apt update -y
apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes

apt install -y sudo vim git wget net-tools jq
