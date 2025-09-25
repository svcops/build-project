# shellcheck disable=SC2155,SC2318
declare -r GREEN='\033[0;32m'      # 绿色
declare -r ORANGE='\033[38;5;208m' # 橙色
declare -r RED='\033[0;31m'        # 红色
declare -r NC='\033[0m'            # reset

# 通用日志函数
_log() {
  local level="$1" color="$2" remark="${3:-$level}" msg="${4:-- - - - - - -}"
  local ts=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "${color}${ts} - [${level^^}] [ ${remark} ] ${msg}${NC}"
}

log() {
  local remark="$1"
  local msg="$2"
  [[ -z "$remark" ]] && remark="info"
  [[ -z "$msg" ]] && msg="- - - - - - -"
  local ts=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "$ts - [INFO ] [ $remark ] $msg"
}

# 具体封装
log_info() { _log "INFO " "$GREEN" "$@"; }
log_warn() { _log "WARN " "$ORANGE" "$@"; }
log_error() { _log "ERROR" "$RED" "$@"; }

line_break() {
  echo -e "\n"
}
