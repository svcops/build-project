#!/bin/bash

# remove proxy
function apt_remove_proxy() {
  rm -rf "/etc/apt/apt.conf.d/proxy.conf"
}

function apt_add_proxy() {
  apt_remove_proxy
  mkdir -p "/etc/apt/apt.conf.d"
  cat >"/etc/apt/apt.conf.d/proxy.conf" <<EOF
Acquire::http::Proxy "socks5h://127.0.0.1:1080";
Acquire::https::Proxy "socks5h://127.0.0.1:1080";
Acquire::socks::Proxy "socks5h://127.0.0.1:1080";
EOF
}

action=$1

if [ "$action" == "add" ]; then
  apt_add_proxy
else
  apt_remove_proxy
fi
