#!/bin/bash
# shellcheck disable=SC1090 disable=SC2034 disable=SC2086
source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)

source <(curl -SL $ROOT_URI/func/log.sh)
source <(curl -SL $ROOT_URI/func/command_exists.sh)

log "command_exists" "ufw"

function detect_ssh_port() {
  ssh_port=$(bash <(curl -SL $ROOT_URI/func/ssh_port.sh))
  log "ssh_port" "ssh port is $ssh_port"
}

detect_ssh_port

function install_ufw() {
  apt-get install -y ufw
  log "ufw_config" "IPV6=no"
}

function config_ufw() {
  if [ -f "/etc/default/ufw" ]; then
    sed -i 's/IPV6=yes/IPV6=no/g' /etc/default/ufw
  fi
}

function enable_ufw() {
  log "ufw" "enable_ufw"
  systemctl enable ufw
  echo -e "y\n" | ufw enable
  ufw status
}

function ufw_allow_ssh() {
  log "ufw" "ufw_allow_ssh"
  ufw allow $ssh_port
  ufw reload
  ufw status
}

function ufw_allow_80_443() {
  log "ufw" "ufw_allow_ssh"
  #  ufw allow 80
  #  ufw allow 443
  #  ufw reload
  #  ufw status
}

function tips() {
  log "tips" "install strategy: oi (only install and do not config), oics (install and config ssh)"
  log "tips" "e.g.: bash <(curl -SL $ROOT_URI/linux/ufw/install_apt.sh) oi"
  log "tips" "e.g.: bash <(curl -SL $ROOT_URI/linux/ufw/install_apt.sh) oics"
}

strategy=$1

if command_exists ufw; then

  echo "ufw is installed."
  if [ "$strategy" == "oics" ]; then
    enable_ufw
    config_ufw
    ufw_allow_ssh
    ufw_allow_80_443
  else
    tips
  fi

else

  echo "ufw is NOT installed."
  if [ "$strategy" == "oi" ]; then
    install_ufw
  elif [ "$strategy" == "oics" ]; then
    install_ufw
    enable_ufw
    config_ufw
    ufw_allow_ssh
    ufw_allow_80_443
  else
    tips
  fi

fi
