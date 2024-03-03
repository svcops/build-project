#!/bin/bash
# shellcheck disable=SC2034
sshd_config_file="/etc/ssh/sshd_config"

if [ ! -f $sshd_config_file ]; then
  echo "22"
  exit
fi

output=$(grep '^Port' /etc/ssh/sshd_config)

if [ -z "$output" ]; then
  ssh_port="22"
else
  ssh_port=$(echo "$output" | cut -d ' ' -f 2)
fi

echo "$ssh_port"
