#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/basic.sh)

source <(curl -sSL $ROOT_URI/func/log.sh)
source <(curl -sSL $ROOT_URI/func/command_exists.sh)

os_base_name=""
os_base_version=""
os_name=""
os_full_name=""

if [ ! -f "/etc/os-release" ]; then
  echo "cannot detect os"
  exit
fi

if ! command_exists sudo; then
  log "command_exists" "command sudo does not exists"
  exit
fi

# use $ID
source /etc/os-release

if ! command_exists lsb_release; then
  log "detect_os" "try install lsb-release"
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
    log "detect_os" "install lsb-release failed"
    exit 1
    ;;
  esac
fi

if ! command_exists lsb_release; then
  log "command_exists" "command lsb_release does not exists"
  exit
fi

os_base_name="$(lsb_release --id --short)"
os_base_version="$(lsb_release -rs | cut -f1 -d.)"
os_name="$(lsb_release --id --short)$(lsb_release -rs | cut -f1 -d.)"
os_full_name="$(lsb_release --id --short)$(lsb_release -rs)"

log "detect_os" "os_base_name = $os_base_name"
log "detect_os" "os_base_version = $os_base_version"
log "detect_os" "os_name = $os_name"
log "detect_os" "os_full_name = $os_full_name"
