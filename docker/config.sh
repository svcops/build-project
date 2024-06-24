#!/bin/bash
# shellcheck disable=SC1090 disable=SC2154 disable=SC2086
source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/basic.sh)

source <(curl -sSL $ROOT_URI/func/log.sh)
source <(curl -sSL $ROOT_URI/func/date.sh)
config_path="/etc/docker/daemon.json"
function write_docker_config() {
  log "config" "write docker config"
  cat >"$config_path" <<EOF
{
  "insecure-registries": [],
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn"
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

if [ -f "$config_path" ]; then
  log "backup" "cp $config_path ${config_path}_${datetime_version}"
  cp "$config_path" "${config_path}_${datetime_version}"
  write_docker_config
  exit
fi

mkdir -p "/etc/docker/"
write_docker_config
