#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086
# source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
ROOT_URI=https://code.kubectl.net/devops/build-project/raw/branch/main

source <(curl -SL $ROOT_URI/func/log.sh)
source <(curl -SL $ROOT_URI/func/command_exists.sh)

log "wsr build" ">>> writerside build start <<<"
function end() {
  log "wsr build" ">>> writerside build end <<<"
}

# writer side 构建的镜像
# build_image="registry.cn-shanghai.aliyuncs.com/iproute/wrs-builder:233.14938"
# build_image="registry.cn-shanghai.aliyuncs.com/iproute/wrs-builder:241.15989"
# build_image="registry.cn-shanghai.aliyuncs.com/iproute/wrs-builder:241.16003"
build_image="registry.cn-shanghai.aliyuncs.com/iproute/wrs-builder:241.18775"

function tips() {
  log_info "tips" "-d writerside build directory"
  log_info "tips" "-i writerside build instance"
}

build_dir=""
instance=""

while getopts ":d:i:" opt; do
  case ${opt} in
  d)
    log_info "get opts" "build_dir is : $OPTARG"
    build_dir=$OPTARG
    ;;
  i)
    log_info "get opts" "instance is : $OPTARG"
    instance=$OPTARG
    ;;
  \?)
    log_error "get opts" "Invalid option: -$OPTARG"
    tips
    end
    exit 1
    ;;
  :)
    log_error "get opts" "Invalid option: -$OPTARG requires an argument"
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
    log_error "validate_param" "parameter $key is empty, then exit"
    tips
    end
    exit 1
  else
    log "validate_param" "parameter $key : $value"
  fi
}

validate_param "instance" "$instance"

if [ -z "$build_dir" ]; then
  log_info "build_dir" "build_dir is empty then use current directory"
  build_dir="$(pwd)"
fi

if [ ! -d "$build_dir" ]; then
  log_error "build_dir" "$build_dir does not exist,exit"
  tips
  end
  exit 1
fi

if [ ! -d "$build_dir/Writerside" ]; then
  log_error "Writerside" "Writerside dir does not exist,exit"
  tips
  end
  exit 1
fi

if [ -d "$build_dir/output" ]; then
  log_info "clear" "rm -rf output"
  rm -rf output
fi

if command_exists docker; then
  log_info "command_exists" "docker command exists"
else
  log_error "command_exists" "docker command does not exist"
  end
  exit 1
fi

docker run --rm \
  -v "$build_dir:/opt/sources" \
  -e INSTANCE="$instance" \
  $build_image
