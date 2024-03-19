#!/bin/bash
# shellcheck disable=SC1090 disable=SC2155
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)

source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/command_exists.sh)

# Debian or Ubuntu
OS=""

# 判断是 Debian 还是 Ubuntu
function detect_os() {
  local os_release="/etc/os-release"
  if [ ! -f $os_release ]; then
    OS="Unknown"
    return
  fi

  local os_name="$(. /etc/os-release && echo "$NAME")"
  log "detect_os" "current system is $os_name"
  if [[ $os_name =~ "Ubuntu" ]]; then
    OS="Ubuntu"
  elif [[ $os_name =~ "Debian" ]]; then
    OS="Debian"
  else
    OS="Unknown"
  fi
}

detect_os

# 判断docker命令是否存在
function docker_exists() {
  if command_exists docker; then
    log "prepare" "Warning: the \"docker\" command appears to already exist on this system"
    log "prepare" "    "
    log "prepare" "If you already have Docker installed, this script can cause trouble, which is"
    log "prepare" "why we're displaying this warning and provide the opportunity to cancel the"
    log "prepare" "installation."
    log "prepare" "    "
    log "prepare" "If you installed the current Docker package using this script and are using it"
    log "prepare" "again to update Docker, you can safely ignore this message."
    log "prepare" "    "
    exit
  fi
}

docker_exists

function tips() {
  log "tips" "SRC 为脚本的参数,源选择,可选 docker(官方源) tsinghua(清华源) aliyun(阿里云)"
  log "tips" "e.g.: bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/install_apt.sh) tsinghua"
  log "tips" "e.g.: bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/install_apt.sh) aliyun"
  log "tips" "e.g.: bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/install_apt.sh) docker"
}

SRC=$1

function do_install() {

  if [ "$OS" == "Debian" ]; then
    # install docker on Debian
    if [ "$SRC" == "docker" ]; then
      log "install" "当前的操作系统为 $OS, 选择的安装源为 $SRC"
      bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/debian/install.sh)
    elif [ "$SRC" == "tsinghua" ]; then
      log "install" "当前的操作系统为 $OS, 选择的安装源为 $SRC"
      bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/debian/install_tsinghua.sh)
    elif [ "$SRC" == "aliyun" ]; then
      log "install" "当前的操作系统为 $OS, 选择的安装源为 $SRC"
      bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/debian/install_aliyun.sh)
    else
      tips
    fi

  elif [ "$OS" == "Ubuntu" ]; then
    # install docker on Ubuntu
    if [ "$SRC" == "docker" ]; then
      log "install" "当前的操作系统为 $OS, 选择的安装源为 $SRC"
      bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/ubuntu/install.sh)
    elif [ "$SRC" == "tsinghua" ]; then
      log "install" "当前的操作系统为 $OS, 选择的安装源为 $SRC"
      bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/ubuntu/install_tsinghua.sh)
    elif [ "$SRC" == "aliyun" ]; then
      log "install" "当前的操作系统为 $OS, 选择的安装源为 $SRC"
      bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/ubuntu/install_aliyun.sh)
    else
      tips
    fi

  else
    tips
  fi
}

do_install

function config_docker() {
  log "config docker" "systemctl enable docker"
  systemctl enable docker
  log "config docker" "systemctl is-enabled docker is $(systemctl is-enabled docker)"
}

config_docker
