#!/bin/bash
# shellcheck disable=SC1090 disable=SC2034
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/command_exists.sh)

log "command_exists" "ufw"

function detect_ssh_port() {
  ssh_port=$(bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/ssh_port.sh))
  log "ssh_port" "ssh port is $ssh_port"
}

detect_ssh_port

function install_ufw() {
  apt install -y ufw
}

function enable_ufw() {
  log "ufw" "enable_ufw"
  systemctl enable ufw
  ufw enable
  ufw status
}

function ufw_allow_ssh() {
  log "ufw" "ufw_allow_ssh"
  ufw allow $ssh_port
  ufw reload
  ufw status
}

function tips() {
  log "tips" "install strategy: oi (only install and do not config), oics (install and config ssh)"
  log "tips" "e.g.: bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/linux/ufw/install_apt.sh) oi"
  log "tips" "e.g.: bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/linux/ufw/install_apt.sh) oics"
}

if command_exists ufw; then
  echo "ufw is installed."
else
  echo "ufw is NOT installed."
fi

strategy=$1

if [ "$strategy" == "oi" ]; then
  install_ufw
elif [ "$strategy" == "oics" ]; then
  install_ufw
  enable_ufw
  ufw_allow_ssh
else
  tips
fi
