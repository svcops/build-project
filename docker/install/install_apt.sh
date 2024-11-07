#!/bin/bash
# shellcheck disable=SC1090 disable=SC2155 disable=SC2086
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
echo -e "\033[0;32mROOT_URI=$ROOT_URI\033[0m"
# ROOT_URI=https://dev.kubectl.net

source <(curl -SL $ROOT_URI/func/log.sh)
source <(curl -SL $ROOT_URI/func/command_exists.sh)

# Debian or Ubuntu
OS=""

# 判断是 Debian 还是 Ubuntu
function detect_os() {
  local os_release="/etc/os-release"
  if [ ! -f $os_release ]; then
    OS="Unknown"
    log_error "detect_os" "can't find file os_release "
    return
  fi

  local os_name="$(. /etc/os-release && echo "$NAME")"
  log "detect_os" "current os is $os_name"
  if [[ $os_name =~ "Ubuntu" ]]; then
    OS="ubuntu"
  elif [[ $os_name =~ "Debian" ]]; then
    OS="debian"
  else
    OS="Unknown"
  fi
}

detect_os

# 判断docker命令是否存在
if command_exists docker; then
  log_warn "prepare" "Warning: the \"docker\" command appears to already exist on this system"
  log_warn "prepare" "    "
  log_warn "prepare" "If you already have Docker installed, this script can cause trouble, which is"
  log_warn "prepare" "why we're displaying this warning and provide the opportunity to cancel the"
  log_warn "prepare" "installation."
  log_warn "prepare" "    "
  log_warn "prepare" "If you installed the current Docker package using this script and are using it"
  log_warn "prepare" "again to update Docker, you can safely ignore this message."
  log_warn "prepare" "    "
  exit
fi

function tips() {
  log_info "tips" "SRC 为脚本的参数,源选择,可选 docker(官方源) tsinghua(清华源) aliyun(阿里云) intellij(镜像)"
  log_info "tips" "e.g.: bash <(curl -SL $ROOT_URI/docker/install/install_apt.sh) tsinghua"
  log_info "tips" "e.g.: bash <(curl -SL $ROOT_URI/docker/install/install_apt.sh) aliyun"
  log_info "tips" "e.g.: bash <(curl -SL $ROOT_URI/docker/install/install_apt.sh) docker"
  log_info "tips" "e.g.: bash <(curl -SL $ROOT_URI/docker/install/install_apt.sh) intellij"
}

SRC=$1

function do_install() {

  if [ "$OS" == "debian" ] || [ "$OS" == "ubuntu" ]; then
    if [ "$SRC" == "docker" ] || [ "$SRC" == "tsinghua" ] || [ "$SRC" == "aliyun" ] || [ "$SRC" == "intellij" ]; then
      log_info "install" "当前的操作系统为 $OS, 选择的安装源为 $SRC"
      bash <(curl -SL $ROOT_URI/docker/install/$OS/install_$SRC.sh)
    else
      tips
      exit 1
    fi
  else
    tips
    exit 1
  fi
}

do_install

function config_docker() {
  log_info "config docker" "systemctl enable docker"
  systemctl enable docker
  log_info "config docker" "systemctl is-enabled docker is $(systemctl is-enabled docker)"
}

config_docker
