#!/bin/bash
# shellcheck disable=SC1090 disable=SC2034 disable=SC2086
source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
# ROOT_URI=https://dev.kubectl.net

source <(curl -SL $ROOT_URI/func/log.sh)
source <(curl -SL $ROOT_URI/func/command_exists.sh)

log_info "ufw" "config ufw"

function detect_ssh_port() {
  ssh_port=$(bash <(curl -SL $ROOT_URI/func/ssh_port.sh))
  log_info "ssh_port" "ssh port is $ssh_port"
}

detect_ssh_port

function install_ufw() {
  apt-get install -y ufw
}

function config_ufw() {
  log_info "ufw_config" "IPV6=no"
  if [ -f "/etc/default/ufw" ]; then
    sed -i 's/IPV6=yes/IPV6=no/g' /etc/default/ufw
  fi
}

function enable_ufw() {
  log_info "ufw" "enable_ufw"
  systemctl enable ufw
  echo -e "y\n" | ufw enable
  ufw status
}

function ufw_allow_ssh() {
  log_info "ufw" "ufw_allow_ssh"
  ufw allow $ssh_port
  ufw reload
  ufw status
}

function ufw_allow_80_443() {
  log_info "ufw" "ufw_allow_ssh"
  #  ufw allow 80
  #  ufw allow 443
  #  ufw reload
  #  ufw status
}

function tips() {
  log_info "tips" "install strategy: oi (only install and do not config), oics (install and config ssh)"
  log_info "tips" "e.g.: bash <(curl -SL $ROOT_URI/linux/ufw/install_apt.sh) oi"
  log_info "tips" "e.g.: bash <(curl -SL $ROOT_URI/linux/ufw/install_apt.sh) oics"
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
