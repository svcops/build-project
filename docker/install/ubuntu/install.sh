#!/bin/bash
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

log "prepare" "Run the following command to uninstall all conflicting packages"

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

log "install" "install docker"
# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update -y

log "install" "apt-get install ..."

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
