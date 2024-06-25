GREEN='\033[0;32m' # 绿色
RED='\033[0;31m'   # 红色
NC='\033[0m'       # reset

function log() {
  local remark="$1"
  local msg="$2"
  if [ -z "$remark" ]; then
    remark="unknown remark"
  fi
  if [ -z "$msg" ]; then
    msg="unknown message"
  fi
  # shellcheck disable=SC2155
  local now=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "$now - [ $remark ] $msg"
}

function log_info() {
  local remark="$1"
  local msg="$2"
  if [ -z "$remark" ]; then
    remark="unknown remark"
  fi
  if [ -z "$msg" ]; then
    msg="unknown message"
  fi
  # shellcheck disable=SC2155
  local now=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "${GREEN}$now - [ $remark ] $msg${NC}"
}

function log_error() {
  local remark="$1"
  local msg="$2"
  if [ -z "$remark" ]; then
    remark="unknown remark"
  fi
  if [ -z "$msg" ]; then
    msg="unknown message"
  fi
  # shellcheck disable=SC2155
  local now=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "${RED}$now - [ $remark ] $msg${NC}"
}
