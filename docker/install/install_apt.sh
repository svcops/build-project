#!/bin/bash
# shellcheck disable=SC1090
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)

# debian or ubuntu
OS=$1
SRC=$2

function tips() {
  log "tips" "OS  为脚本的第一个参数,操作系统选择,可选 debian ubuntu"
  log "tips" "SRC 为脚本的第二个参数,源选择,可选 docker(官方源) tsinghua(清华源)"
  log "tips" "e.g.: bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/install_apt.sh) ubuntu tsinghua"
  log "tips" "e.g.: bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/install_apt.sh) debian docker"
}

if [ "$OS" == "debian" ]; then

  if [ "$SRC" == "docker" ]; then
    log "install" "当前的操作系统为 $OS, 当前的源为 $SRC"
    bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/debian/install.sh)
  elif [ "$SRC" == "tsinghua" ]; then
    log "install" "当前的操作系统为 $OS, 当前的源为 $SRC"
    bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/debian/install_tsinghua.sh)
  else
    tips
  fi

elif [ "$OS" == "ubuntu" ]; then

  if [ "$SRC" == "docker" ]; then
    log "install" "当前的操作系统为 $OS, 当前的源为 $SRC"
    bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/ubuntu/install.sh)
  elif [ "$SRC" == "tsinghua" ]; then
    log "install" "当前的操作系统为 $OS, 当前的源为 $SRC"
    bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/ubuntu/install_tsinghua.sh)
  else
    tips
  fi

else
  tips
fi

function config_docker() {
  log "config docker" "systemctl enable docker"
  systemctl enable docker
  log "config docker" "systemctl is-enabled docker is $(systemctl is-enabled docker)"
}

config_docker
