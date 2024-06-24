#!/bin/bash

# remove proxy
function apt_remove_proxy() {
  rm -rf "/etc/apt/apt.conf.d/proxy.conf"
}

function apt_add_proxy() {
  apt_remove_proxy
  cat >"/etc/apt/apt.conf.d/proxy.conf" <<EOF
Acquire::http::Proxy "socks5h://127.0.0.1:1080";
Acquire::https::Proxy "socks5h://127.0.0.1:1080";
Acquire::socks::Proxy "socks5h://127.0.0.1:1080";
EOF
}

function bashrc_remove_proxy() {
  sed -i '/^#4fe2411d-109a-4e92-82e8-9d612024b8e6/,/#c3f0e7a4-de15-4879-9845-01e53f3e8a2c/d' /root/.bashrc
}

function bashrc_config_proxy() {
  bashrc_remove_proxy
  cat <<EOF >>/root/.bashrc
#4fe2411d-109a-4e92-82e8-9d612024b8e6
export ALL_PROXY=socks5h://127.0.0.1:1080
export HTTP_PROXY=socks5h://127.0.0.1:1080
export HTTPS_PROXY=socks5h://127.0.0.1:1080

# apt install tsocks
alias wget='tsocks wget'
#c3f0e7a4-de15-4879-9845-01e53f3e8a2c
EOF
}

action=$1

if [ "$action" == "add" ]; then
  apt_add_proxy
  bashrc_config_proxy
else
  apt_remove_proxy
  bashrc_remove_proxy
fi

# export ALL_PROXY=socks5h://127.0.0.1:1080
# export HTTP_PROXY=socks5h://127.0.0.1:1080
# export HTTPS_PROXY=socks5h://127.0.0.1:1080
# alias wget='tsocks wget'
