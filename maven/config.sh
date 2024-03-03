#!/bin/bash
# shellcheck disable=SC1090
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)

now=$(date +"%Y-%m-%d %H:%M:%S")

log "create folder" "try create m2 folder"
mkdir -p "$HOME/.m2"

function backup_settings() {
  if [ -f "$HOME/.m2/settings.xml" ]; then
    log "backup" "from settings.xml to settings_$now.xml"
    mv "$HOME/.m2/settings.xml" "$HOME/.m2/settings_$now.xml"
  fi
}

backup_settings

function download_settings() {
  curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/maven/settings.xml -o "$HOME/.m2/settings.xml"
  log "show settings" "ls -l $HOME/.m2/"
}

download_settings
