#!/bin/bash
# shellcheck disable=SC1090 disable=SC2154 disable=SC2086
source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
source <(curl -SL $ROOT_URI/func/log.sh)
source <(curl -SL $ROOT_URI/func/date.sh)

if [ ! -d "/etc/apt/" ]; then
  log_error "proxy_apt occurred error: directory /etc/apt/ does not exist"
  exit
fi

PROXY_URL=$1

if [ -z $PROXY_URL ]; then
  log_error "validate" "proxy url is blank"
  log_info "proxy url" "e.g. http://127.0.0.1:8888"
  log_info "proxy url" "e.g. socks5h://127.0.0.1:1080"
  exit 1
fi

function apt_add_proxy() {
  apt_remove_proxy
  mkdir -p "/etc/apt/apt.conf.d"
  cat >"/etc/apt/apt.conf.d/proxy.conf" <<EOF
Acquire::http::Proxy "$PROXY_URL";
Acquire::https::Proxy "$PROXY_URL";
Acquire::socks::Proxy "$PROXY_URL";
EOF
}

apt_add_proxy
