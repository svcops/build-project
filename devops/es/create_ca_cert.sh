#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086 disable=SC2155 disable=SC2128 disable=SC2028 disable=SC2162
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
echo -e "\033[0;32mROOT_URI=$ROOT_URI\033[0m"
# ROOT_URI=https://dev.kubectl.net

source <(curl -SL $ROOT_URI/func/log.sh)
source <(curl -SL $ROOT_URI/func/command_exists.sh)

log_info "elasticsearch" "create ca and cert"

log_info "elasticsearch" "step 1 prepare"

SHELL_FOLDER=$(cd "$(dirname "$0")" && pwd)

target_dir=$SHELL_FOLDER/cert

function prepare() {
  if ! command_exists docker; then
    log_error "elasticsearch" "docker is not installed"
    exit 1
  fi

  if [ -d $target_dir ]; then
    log_info "elasticsearch" "$target_dir is exist"
    read -p "Do you want to delete it? [y/n]" answer
    if [ $answer == "y" ]; then
      rm -rf $target_dir
      mkdir -p $target_dir
    else
      log_info "elasticsearch" "exit"
      exit 0
    fi
  fi
}

prepare

log_info "elasticsearch" "step 2 create ca"

log_info "elasticsearch" "step 3 create cert"
