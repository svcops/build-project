#!/bin/bash
# shellcheck disable=SC1090
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/command_exists.sh)

os_name=""

if [ ! -f "/etc/os-release" ]; then
  echo "cannot detect os"
  exit
fi

source /etc/os-release

if ! command_exists sudo; then
  log "command_exists" "command sudo does not exists"
  exit
fi

case $ID in
debian | ubuntu | devuan)
  sudo apt-get install lsb-release -y
  ;;
centos | fedora | rhel)
  yumdnf="yum"
  if test "$(echo "$VERSION_ID >= 22" | bc)" -ne 0; then
    yumdnf="dnf"
  fi
  sudo $yumdnf install -y redhat-lsb-core -y
  ;;
*)
  exit 1
  ;;
esac

if ! command_exists lsb_release; then
  log "command_exists" "command lsb_release does not exists"
  exit
fi

os_name="$(lsb_release --id --short)$(lsb_release -rs | cut -f1 -d.)"

log "detect_os" "os is $os_name"

