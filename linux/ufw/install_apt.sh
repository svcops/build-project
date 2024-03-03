#!/bin/bash
# shellcheck disable=SC1090 disable=SC2034
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/command_exists.sh)

log "command_exists" "ufw"

function detect_ssh_port() {
  bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/ssh_port.sh)
  ssh_port=$?
  log "ssh_port" "ssh port is $ssh_port"
}

detect_ssh_port

if command_exists ufw; then
  echo "ufw is installed."
  # todo
else
  echo "ufw is NOT installed."
  # todo
fi
