#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
echo -e "\033[0;32mROOT_URI=$ROOT_URI\033[0m" && export ROOT_URI=$ROOT_URI
# ROOT_URI=https://dev.kubectl.net

source <(curl -sSL $ROOT_URI/func/log.sh)
bash <(curl -sSL $ROOT_URI/docker/install/uninstall_apt.sh)

function install_docker() {
  local os="$1"
  local src="$2"

  log_info "show" "os is $1|mirror is $src"

  log_info "install" "install docker"
  # Add Docker's official GPG key:
  sudo apt-get update -y
  sudo apt-get install ca-certificates curl -y
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL "$src/linux/$os/gpg" -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] $src/linux/$os \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  log "install" "apt-get install ..."
  sudo apt-get update -y
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

}

# os src
install_docker "$1" "$2"
