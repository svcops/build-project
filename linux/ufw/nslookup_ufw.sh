#!/bin/bash
# shellcheck disable=SC2164 disable=SC2155 disable=SC2046 disable=SC2086

DOMAIN=$1
DNS_SERVER=$2
IP_CACHE_FILE=$3

# -------------------------------
# 日志函数
# -------------------------------
log() {
  local remark="${1:-unknown remark}"
  local msg="${2:-unknown message}"
  local now
  now=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "$now - [INFO ] [ $remark ] $msg"
}

# -------------------------------
# 工具函数
# -------------------------------
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

validate_ipv4() {
  local ip=$1
  [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
}

# -------------------------------
# 前置检查
# -------------------------------
prepare() {
  if ! command_exists nslookup; then
    log "check" "nslookup command not found"
    exit 1
  fi
}

# -------------------------------
# 获取域名 IP
# -------------------------------
get_domain_ip() {
  local domain=$1
  local dns_server=$2
  local result ip_line

  result=$(nslookup "$domain" "$dns_server" 2>/dev/null | grep "Address:")

  # 取最后一行 IP
  if [ "$(echo "$result" | wc -l)" -ge 2 ]; then
    ip_line=$(echo "$result" | tail -n 1 | awk '{print $2}')
    echo "$ip_line"
  else
    echo ""
  fi
}

# -------------------------------
# 缓存与 UFW 处理
# -------------------------------
update_ufw() {
  local domain_ip=$1
  local cache_ip=""

  # 读取缓存
  if [[ -f "$IP_CACHE_FILE" ]]; then
    cache_ip=$(<"$IP_CACHE_FILE")
  fi

  # 校验缓存 IP，否则重置
  if ! validate_ipv4 "$cache_ip"; then
    cache_ip=""
  fi

  # UFW 检查
  if ! command_exists /usr/sbin/ufw; then
    log "ufw" "ufw command not found"
    return
  fi

  # IP 变更时更新规则
  if [[ "$cache_ip" != "$domain_ip" ]]; then
    if [[ -n "$cache_ip" ]]; then
      local delete_result
      delete_result=$(/usr/sbin/ufw --force delete allow from "$cache_ip" to any port 443 2>&1)
      log "ufw" "delete [$cache_ip]: $delete_result"
    fi
    local allow_result
    allow_result=$(/usr/sbin/ufw allow from "$domain_ip" to any port 443 2>&1)
    log "ufw" "allow  [$domain_ip]: $allow_result"
  else
    # 如果规则已存在就跳过
    if /usr/sbin/ufw status | grep -q "$domain_ip.*443"; then
      log "ufw" "already allowed: $domain_ip"
    else
      local allow_result
      allow_result=$(/usr/sbin/ufw allow from "$domain_ip" to any port 443 2>&1)
      log "ufw" "re-allow [$domain_ip]: $allow_result"
    fi
  fi

  echo "$domain_ip" >"$IP_CACHE_FILE"
}

# -------------------------------
# 主流程
# -------------------------------
main() {
  prepare

  local domain_ip
  domain_ip=$(get_domain_ip "$DOMAIN" "$DNS_SERVER")

  log "dns" "domain=$DOMAIN, ip=$domain_ip"

  if ! validate_ipv4 "$domain_ip"; then
    log "validate" "domain ip is not valid"
    exit 1
  fi

  update_ufw "$domain_ip"
}

main "$@"

# update to doh https://doh.pub/dns-query?name=google.com&type=A
