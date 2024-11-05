#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086
if [ -z $ROOT_URI ]; then
  source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
else
  echo -e "\033[0;32mROOT_URI=$ROOT_URI\033[0m"
fi
# ROOT_URI=https://dev.kubectl.net

source <(curl -SL $ROOT_URI/func/log.sh)

# debian 系卸载 docker

log_warn "uninstall" "try stop docker.socket & docker"

sudo systemctl stop docker.socket
sudo systemctl stop docker

sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

log_warn "uninstall" "rm -rf /var/lib/docker"
sudo rm -rf /var/lib/docker

log_warn "uninstall" "rm -rf /var/lib/containerd"
sudo rm -rf /var/lib/containerd

log_warn "uninstall" "Run the following command to uninstall all conflicting packages"

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
