#!/bin/bash
# shellcheck disable=SC2155,SC2318
_log() {
  local level="$1" color="$2" remark="$3" msg="$4"
  local ts=$(date +"%Y-%m-%d %H:%M:%S")

  local NC='\033[0m' # reset
  # 判断参数组合
  if [[ -n "$remark" && -n "$msg" ]]; then
    echo -e "${color}${ts} - [${level^^}] [ ${remark} ] ${msg}${NC}"
  elif [[ -n "$remark" ]]; then
    echo -e "${color}${ts} - [${level^^}] ${remark}${NC}"
  else
    echo -e "${color}${ts} - [${level^^}]${NC}"
  fi
}

log() {
  local ts=$(date +"%Y-%m-%d %H:%M:%S")

  if [[ -n "$1" && -n "$2" ]]; then
    echo -e "$ts - [INFO ] [ $1 ] $2"
  elif [[ -n "$1" ]]; then
    echo -e "$ts - [INFO ] $1"
  else
    echo -e "$ts - [INFO ]"
  fi
}

# 具体封装
log_info() { _log "INFO " "\033[0;34m" "$@"; }
log_warn() { _log "WARN " "\033[38;5;208m" "$@"; }
log_error() { _log "ERROR" "\033[0;31m" "$@"; }

line_break() {
  echo -e "\n"
}
