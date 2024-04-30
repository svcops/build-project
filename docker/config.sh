#!/bin/bash
# shellcheck disable=SC1090 disable=SC2154
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/date.sh)
config_path="/etc/docker/daemon.json"
function write_docker_config() {
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
  log "backup" "cp $config_path ${config_path}_${datatime_version}"
  write_docker_config
  exit
fi

mkdir -p "/etc/docker/"
write_docker_config
