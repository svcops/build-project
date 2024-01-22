# shellcheck disable=SC2155
function log() {
  local log_remark="$1"
  local log_message="$2"
  if [ -z "$log_remark" ]; then
    log_remark="default remark"
  fi
  if [ -z "$log_message" ]; then
    log_message="default message"
  fi
  local current_time=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "$current_time - [ $log_remark ] $log_message"
}