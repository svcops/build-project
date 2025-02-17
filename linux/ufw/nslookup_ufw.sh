#!/bin/bash
# shellcheck disable=SC2164 disable=SC2155 disable=SC2046 disable=SC2086
DOMAIN=$1
DNS_SERVER=$2
IP_CACHE_FILE=$3

function log() {
  local remark="$1"
  local msg="$2"
  if [ -z "$remark" ]; then
    remark="unknown remark"
  fi
  if [ -z "$msg" ]; then
    msg="unknown message"
  fi
  local now=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "$now - [INFO ] [ $remark ] $msg"
}

function command_exists() {
  type $1 &>/dev/null
}

function validate_ipv4() {
  local ip=$1
  if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    return 0
  else
    return 1
  fi
}

function prepare() {
  if ! command_exists nslookup; then
    log "nslookup" "nslookup command not found"
  fi
}

function getDomainIp() {
  local domain=$1
  local dns_server=$2

  # success
  #Server:         223.5.5.5
  #Address:        223.5.5.5#53
  #
  #Non-authoritative answer:
  #Name:   www.example.com
  #Address: 127.0.0.1

  # failure
  #Server:         223.5.5.5
  #Address:        223.5.5.5#53
  #
  #** server can't find test.nginx.com: NXDOMAIN

  local ip=$(nslookup "$domain" "$dns_server" | grep "Address:")
  if [ $(echo "$ip" | wc -l) -ge 2 ]; then
    domainIp=$(echo "$ip" | tail -n 1 | awk '{print $2}')
  else
    domainIp=""
  fi
}

getDomainIp "$DOMAIN" "$DNS_SERVER"

log "getDomainIp" "domain=$DOMAIN, ip=$domainIp"

if ! validate_ipv4 "$domainIp"; then
  log "validate" "domain ip is not valid"
  exit
fi

function cacheOption() {

  if [ ! -f $IP_CACHE_FILE ]; then
    echo "$domainIp" >$IP_CACHE_FILE
    cacheIp=$domainIp
  else
    cacheIp=$(cat $IP_CACHE_FILE)
    if ! validate_ipv4 "$cacheIp"; then
      echo "$domainIp" >$IP_CACHE_FILE
      cacheIp=$domainIp
    fi
  fi

  if command_exists "/usr/sbin/ufw"; then
    if [ "$cacheIp" != "$domainIp" ]; then
      local delete_result=$(/usr/sbin/ufw delete allow from "$cacheIp" to any port 443)
      local allow_result=$(/usr/sbin/ufw allow from "$domainIp" to any port 443)
      log "ufw" "delete: $delete_result"
      log "ufw" "allow:  $allow_result"
    else
      if [ $(/usr/sbin/ufw status | grep "$domainIp" | grep "443" | wc -l) -ge 1 ]; then
        log "ufw" "already allowed: $domainIp"
      else
        local allow_result=$(/usr/sbin/ufw allow from "$domainIp" to any port 443)
        log "ufw" "allow:  $allow_result"
      fi
    fi
    echo "$domainIp" >$IP_CACHE_FILE
  else
    log "ufw" "ufw command not found"
  fi
}

cacheOption
