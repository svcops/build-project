#!/bin/bash
# 彩色日志库，保持可读性，高度可用

# ====== 防重复加载 ======
[[ -n "$_COLOR_LOG_LOADED" ]] && return
_COLOR_LOG_LOADED=1

# ====== 颜色定义 ======
NC='\033[0m'              # reset
TS_COLOR='\033[0;36m'     # 时间青色
REMARK_COLOR='\033[0;36m' # remark 青色

# ====== 内部日志函数 ======
_log() {
  local level="$1" color="$2" remark="$3" msg="$4"
  local ts
  ts=$(date +"%Y-%m-%d %H:%M:%S")

  local level_str="${color}[${level^^}]${NC}"
  local remark_str=""
  [[ -n "$remark" ]] && remark_str="${REMARK_COLOR}[ ${remark} ]${NC} "

  if [[ -n "$remark" && -n "$msg" ]]; then
    echo -e "${TS_COLOR}${ts}${NC} - ${level_str} ${remark_str}${msg}"
  elif [[ -n "$msg" ]]; then
    echo -e "${TS_COLOR}${ts}${NC} - ${level_str} ${msg}"
  else
    echo -e "${TS_COLOR}${ts}${NC} - ${level_str}"
  fi
}

# ====== 日志函数 ======
declare -f log_debug >/dev/null 2>&1 || log_debug() { _log "DEBUG" "\033[0;36m" "$@"; }     # 青色
declare -f log >/dev/null 2>&1 || log() { _log "INFO " "\033[0;34m" "$@"; }                 # 蓝色
declare -f log_info >/dev/null 2>&1 || log_info() { _log "INFO " "\033[0;34m" "$@"; }       # 蓝色
declare -f log_success >/dev/null 2>&1 || log_success() { _log "OK   " "\033[0;32m" "$@"; } # 绿色
declare -f log_warn >/dev/null 2>&1 || log_warn() { _log "WARN " "\033[38;5;208m" "$@"; }   # 橙色
declare -f log_error >/dev/null 2>&1 || log_error() { _log "ERROR" "\033[0;31m" "$@"; }     # 红色
declare -f log_fatal >/dev/null 2>&1 || log_fatal() { _log "FATAL" "\033[1;41;97m" "$@"; }  # 白字红底
declare -f log_notice >/dev/null 2>&1 || log_notice() { _log "NOTE " "\033[0;35m" "$@"; }   # 紫色
declare -f log_trace >/dev/null 2>&1 || log_trace() { _log "TRACE" "\033[0;90m" "$@"; }     # 灰色

# log 作为 info 别名
declare -f log >/dev/null 2>&1 || log() { log_info "$@"; }

# ====== 分隔行 ======
line_break() { echo; }
