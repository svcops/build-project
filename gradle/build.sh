#!/bin/bash
# shellcheck disable=SC2086

function log() {
  local log_remark="$1"
  local log_message="$2"
  if [ -z "$log_remark" ]; then
    log_remark="default remark"
  fi

  if [ -z "$log_message" ]; then
    log_message="default message"
  fi
  local current_time
  current_time=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "$current_time - [ $log_remark ] $log_message"
}

command_exists() {
  # this should return the exit status of 'command -v'
  command -v "$1" >/dev/null 2>&1
}

log "gradle build" ">>> start <<<"

# 构建的缓存
cache=""
# 构建的镜像
image=""
# 构建的命令
build=""

function tips() {
  log "tips" "-c cache"
  log "tips" "-i image"
  log "tips" "-x execute"
}

while getopts ":c:i:x:" opt; do
  case ${opt} in
  c)
    log "getopts" "构建的缓存 docker's volume 为: $OPTARG"
    cache=$OPTARG
    ;;
  i)
    log "getopts" "构建的镜像 docker's image 为: $OPTARG"
    image=$OPTARG
    ;;
  x)
    log "getopts" "构建的命令 gradle's command 为: $OPTARG"
    build=$OPTARG
    ;;
  \?)
    log "getopts" "Invalid option: -$OPTARG"
    tips
    log "gradle build" ">>> end <<<"
    exit 1
    ;;
  :)
    log "getopts" "Invalid option: -$OPTARG requires an argument"
    tips
    log "gradle build" ">>> end <<<"
    exit 1
    ;;
  esac
done

function validate_param() {
  local key=$1
  local value=$2
  if [ -z "$value" ]; then
    log "validate_param" "构建的参数 $key 为空, 退出"
    tips
    log "gradle build" ">>> end <<<"
    exit 1
  else
    log "validate_param" "构建的参数 $key : $value"
  fi
}

validate_param "cache" "$cache"
validate_param "image" "$image"
validate_param "build" "$build"

if command_exists docker; then
  log "command_exists" "docker 命令存在"
else
  log "command_exists" "docker 命令不存在"
  log "gradle build" ">>> end <<<"
  exit 1
fi

log "build" "========== gradle =========="

docker run --rm -u root \
  --network=host \
  -v "$PWD":/home/gradle/project \
  -w /home/gradle/project \
  -v "$cache:/home/gradle/.gradle" \
  "$image" \
  $build

log "gradle build" ">>> end <<<"
