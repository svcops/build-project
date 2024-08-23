#!/bin/bash

function command_exists() {
  type "$1" &>/dev/null
}

if ! command_exists docker; then
  echo "docker command doesn't exist"
  exit
fi

function docker_remove_proxy() {
  rm -rf "/etc/systemd/system/docker.service.d"
}

function docker_add_proxy() {
  mkdir -p "/etc/systemd/system/docker.service.d"
  if [ -f "/etc/systemd/system/docker.service.d/http-proxy.conf" ]; then
    echo "docker proxy file exists,then exit"
    exit
  fi
  cat >"/etc/systemd/system/docker.service.d/http-proxy.conf" <<EOF
[Service]
Environment="HTTP_PROXY=socks5://127.0.0.1:1080" "HTTPS_PROXY=socks5://127.0.0.1:1080"
EOF
}

action=$1

if [ "$action" == "add" ]; then
  docker_add_proxy
else
  docker_remove_proxy
fi
