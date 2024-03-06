#!/bin/bash
# shellcheck disable=SC2155 disable=SC1090
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/command_exists.sh)

if command_exists docker; then
  log "command_exists" "docker 命令存在"
else
  log "command_exists" "docker 命令不存在"
  exit 1
fi
