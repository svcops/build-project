#!/bin/bash
# shellcheck disable=SC1090 disable=SC2154  disable=SC2086
source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)

source <(curl -SL $ROOT_URI/func/log.sh)
source <(curl -SL $ROOT_URI/func/detect_os.sh)

log "update" "update system & prepare"

function apt_upgrade() {
  apt-get update -y
  # WARNING: apt does not have a stable CLI interface. Use with caution in scripts
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" --allow-downgrades --allow-remove-essential --allow-change-held-packages

  apt-get install -y sudo vim git wget net-tools jq lsof tree zip unzip
}

function yum_update() {
  yum update -y
}

if [ "$os_base_name" == "Ubuntu" ] || [ "$os_base_name" == "Debian" ]; then
  apt_upgrade
else
  yum_update
fi
