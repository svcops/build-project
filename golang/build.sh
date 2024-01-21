#!/bin/bash
# shellcheck disable=SC2086
# shellcheck disable=SC2155
# shellcheck disable=SC2126

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

command_exists() {
  # this should return the exit status of 'command -v'
  command -v "$1" >/dev/null 2>&1
}

log "go build" ">>> go build start <<<"
function end() {
  log "go build" ">>> go build end <<<"
}

cache=""
image=""
build=""

function tips() {
  log "tips" "-c user docker volume's to cache the build process"
  log "tips" "-i golang's docker image"
  log "tips" "-x golang's build command"
}

while getopts ":c:i:x:" opt; do
  case ${opt} in
  c)
    log "getopts" "process's cache; docker's volume is: $OPTARG"
    cache=$OPTARG
    ;;
  i)
    log "getopts" "process's image; docker's image is: $OPTARG"
    image=$OPTARG
    ;;
  x)
    log "getopts" "process's command; golang's command is: $OPTARG"
    build=$OPTARG
    ;;
  \?)
    log "getopts" "Invalid option: -$OPTARG"
    tips
    end
    exit 1
    ;;
  :)
    log "getopts" "Invalid option: -$OPTARG requires an argument"
    tips
    end
    exit 1
    ;;
  esac
done

function validate_param() {
  local key=$1
  local value=$2
  if [ -z "$value" ]; then
    log "validate_param" "parameter $key is empty, then exit"
    tips
    end
    exit 1
  else
    log "validate_param" "parameter $key : $value"
  fi
}

validate_param "cache" "$cache"
validate_param "image" "$image"
validate_param "build" "$build"

if command_exists docker; then
  log "command_exists" "docker command exists"
else
  log "command_exists" "docker command does not exist"
  end
  exit 1
fi

log "build" "========== build golang's project in docker =========="

docker run --rm -v "$PWD:/usr/src/myapp" \
  --network=host \
  -w /usr/src/myapp \
  -e CGO_ENABLED=0 \
  -e GOPROXY=https://goproxy.cn,direct \
  -e GOPATH=/opt/go \
  -v $cache:/opt/go \
  "$image" \
  $build

end
