#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086
source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)

source <(curl -SL $ROOT_URI/func/log.sh)

# debian 系卸载 docker

log "uninstall" "try stop docker.socket & docker"

sudo systemctl stop docker.socket
sudo systemctl stop docker

sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

log "uninstall" "rm -rf /var/lib/docker"
sudo rm -rf /var/lib/docker

log "uninstall" "rm -rf /var/lib/containerd"
sudo rm -rf /var/lib/containerd

log "uninstall" "Run the following command to uninstall all conflicting packages"

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
