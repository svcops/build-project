#!/bin/bash
# shellcheck disable=SC1090
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)

# debian or ubuntu
OS=$1
SRC=$2

function tips() {
  log "tips" "OS  为脚本的第一个参数,操作系统选择,可选 debian ubuntu"
  log "tips" "SRC 为叫本滴第二个参数,源选择,可选 docker(官方源) tsinghua(清华源)"
  log "tips" "e.g.: bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/install_apt.sh) debian tsinghua"
}

if [ "$OS" == "debian" ]; then

  if [ "$SRC" == "docker" ]; then
    log "install" "当前的操作系统为 $OS, 当前的源为 $SRC"
    bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/debian/install.sh)
  elif [ "$SRC" == "tsinghua" ]; then
    log "install" "当前的操作系统为 $OS, 当前的源为 $SRC"
    bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/debian/install_cn.sh)
  else
    tips
  fi

elif [ "$OS" == "ubuntu" ]; then

  if [ "$SRC" == "docker" ]; then
    log "install" "当前的操作系统为 $OS, 当前的源为 $SRC"
    bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/ubuntu/install.sh)
  elif [ "$SRC" == "tsinghua" ]; then
    log "install" "当前的操作系统为 $OS, 当前的源为 $SRC"
    bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/ubuntu/install_cn.sh)
  else
    tips
  fi

else
  tips
fi
