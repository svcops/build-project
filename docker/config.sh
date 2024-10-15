#!/bin/bash
# shellcheck disable=SC1090 disable=SC2154 disable=SC2086
source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)

source <(curl -SL $ROOT_URI/func/log.sh)
source <(curl -SL $ROOT_URI/func/date.sh)

registry=$1

if [ -z $registry ]; then
  registry="https://docker.mirrors.ustc.edu.cn"
  log_info "registry" "registry is blank.default: $registry "
fi

config_path="/etc/docker/daemon.json"

if [ -f "$config_path" ]; then
  log "backup" "cp $config_path ${config_path}_${datetime_version}"
  cp "$config_path" "${config_path}_${datetime_version}"
fi

function write_docker_config() {
  log "config" "write docker config"
  cat >"$config_path" <<EOF
{
  "insecure-registries": [],
  "registry-mirrors": [
    "$registry"
  ],
  "exec-opts": [
    "native.cgroupdriver=systemd"
  ],
  "data-root": "/var/lib/docker",
  "log-opts": {
    "max-file": "5",
    "max-size": "20m"
  }
}
EOF
}

mkdir -p "/etc/docker/"
write_docker_config
