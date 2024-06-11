#!/bin/bash
# shellcheck disable=SC1090
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/command_exists.sh)

log "wsr build" ">>> writerside build start <<<"
function end() {
  log "wsr build" ">>> writerside build end <<<"
}

# writer side 构建的镜像
# build_image="registry.cn-shanghai.aliyuncs.com/iproute/wrs-builder:233.14938"
#build_image="registry.cn-shanghai.aliyuncs.com/iproute/wrs-builder:241.15989"
build_image="registry.cn-shanghai.aliyuncs.com/iproute/wrs-builder:241.16003"

function tips() {
  log "tips" "-d writerside build directory"
  log "tips" "-i writerside build instance"
}

build_dir=""
instance=""

while getopts ":d:i:" opt; do
  case ${opt} in
  d)
    log "get opts" "build_dir is : $OPTARG"
    build_dir=$OPTARG
    ;;
  i)
    log "get opts" "instance is : $OPTARG"
    instance=$OPTARG
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

validate_param "instance" "$instance"

if [ -z "$build_dir" ]; then
  log "build_dir" "build_dir is empty then use current directory"
  build_dir="$(pwd)"
fi

if [ ! -d "$build_dir" ]; then
  log "build_dir" "$build_dir does not exist,exit"
  tips
  end
  exit 1
fi

if [ ! -d "$build_dir/Writerside" ]; then
  log "Writerside" "Writerside dir does not exist,exit"
  tips
  end
  exit 1
fi

if [ -d "$build_dir/output" ]; then
  log "clear" "rm -rf output"
  rm -rf output
fi

if command_exists docker; then
  log "command_exists" "docker command exists"
else
  log "command_exists" "docker command does not exist"
  end
  exit 1
fi

docker run --rm \
  -v "$build_dir:/opt/sources" \
  -e INSTANCE="$instance" \
  $build_image
