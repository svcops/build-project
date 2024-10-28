#!/bin/bash
# shellcheck disable=SC2164 disable=SC2086 disable=SC1090
source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
source <(curl -sSL $ROOT_URI/func/log.sh)

log_info "update" "apt-get update & upgrade"

bash <(curl -sSL $ROOT_URI/linux/system/update.sh)

log_info "init" "int bashrc ls"

bash <(curl -sSL $ROOT_URI/linux/system/bashrc/config_bashrc_ls.sh)
