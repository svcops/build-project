#!/bin/bash
# shellcheck disable=SC2086 disable=SC2155 disable=SC2126 disable=SC1090
# source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
ROOT_URI=https://code.kubectl.net/devops/build-project/raw/branch/main

source <(curl -SL $ROOT_URI/func/log.sh)
source <(curl -SL $ROOT_URI/func/command_exists.sh)

log "go build" ">>> go build start <<<"
function end() {
  log "go build" ">>> go build end <<<"
}

cache=""
image=""
build=""
build_dir=""

function tips() {
  log "tips" "-d golang's build directory"
  log "tips" "-c user docker volume's to cache the build process"
  log "tips" "-i golang's docker image"
  log "tips" "-x golang's build command"
}

while getopts ":c:i:x:d:" opt; do
  case ${opt} in
  d)
    log "get opts" "process's build_dir; build_dir is: $OPTARG"
    build_dir=$OPTARG
    ;;
  c)
    log "get opts" "process's cache; docker's volume is: $OPTARG"
    cache=$OPTARG
    ;;
  i)
    log "get opts" "process's image; docker's image is: $OPTARG"
    image=$OPTARG
    ;;
  x)
    log "get opts" "process's command; golang's command is: $OPTARG"
    build=$OPTARG
    ;;
  \?)
    log "get opts" "Invalid option: -$OPTARG"
    tips
    end
    exit 1
    ;;
  :)
    log "get opts" "Invalid option: -$OPTARG requires an argument"
    tips
    end
    exit 1
    ;;
  esac
done

function validate_not_blank() {
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

validate_not_blank "cache" "$cache"
validate_not_blank "image" "$image"
validate_not_blank "build" "$build"

if [ -z "$build_dir" ]; then
  log "build_dir" "build_dir is empty then use current directory"
  build_dir="$(pwd)"
elif [ ! -d "$build_dir" ]; then
  log "build_dir" "build_dir is not a valid paths"
  exit 1
fi

if [[ $cache =~ ^[a-zA-Z0-9_.-]+$ ]]; then
  log "cache_str_validate" "cache str validate success"
else
  log "cache_str_validate" "cache str contains only English characters, digits, underscores, dots, and hyphens."
  log "cache_str_validate" "cache str validate failed"
  exit 1
fi

if command_exists docker; then
  log "command_exists" "docker command exists"
else
  log "command_exists" "docker command does not exist"
  end
  exit 1
fi

log "build" "========== build golang's project in docker =========="

docker run --rm \
  -v "$build_dir:/usr/src/myapp" \
  -w /usr/src/myapp \
  --network=host \
  -e CGO_ENABLED=0 \
  -e GOPROXY=https://goproxy.cn,direct \
  -e GOPATH=/opt/go \
  -v $cache:/opt/go \
  "$image" \
  $build

end
