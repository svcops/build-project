#!/bin/bash
# debian 系卸载 docker
# shellcheck disable=SC1090
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)

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
