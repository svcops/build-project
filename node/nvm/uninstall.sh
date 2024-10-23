#!/bin/bash
# shellcheck disable=SC2164 disable=SC2086 disable=SC1090
source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
source <(curl -sSL $ROOT_URI/func/log.sh)

function delete_npmrc() {
  log_warn "delete" "rm -rf /root/.npmrc"
  rm -rf /root/.npmrc
}

function delete_nvm() {
  log_warn "delete" "rm -rf /root/.nvm"
  rm -rf /root/.nvm
}

function delete_bashrc_content() {
  log_warn "delete" "sed"
  sed -i '/^# NVM CONFIG START$/,/^# NVM CONFIG END$/d' /root/.bashrc
}

delete_npmrc
delete_nvm
delete_bashrc_content
