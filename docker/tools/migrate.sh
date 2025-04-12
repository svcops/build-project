#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086 disable=SC2155 disable=SC2128 disable=SC2028 disable=SC2181 disable=SC2046 disable=SC2162
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
echo -e "\033[0;32mROOT_URI=$ROOT_URI\033[0m"
# ROOT_URI=https://dev.kubectl.net

source <(curl -sSL $ROOT_URI/func/log.sh)
source <(curl -sSL $ROOT_URI/func/command_exists.sh)

log_info "migrate" "migrate docker's image"

if ! command_exists docker; then
  log_error "migrate" "docker not found, please install docker first"
fi

from_image=$1
to_image=$2

if [ -z "$from_image" ]; then
  log_error "migrate" "from_image is empty"
  exit 1
fi

if [ -z "$to_image" ]; then
  log_error "migrate" "to_image is empty"
  exit 1
fi

log_info "migrate" "from_image: $from_image"
log_info "migrate" "to_image: $to_image"

function image_exists() {
  local image_name_tag="$1"
  if [ $(docker image ls $image_name_tag | wc -l) -ge 2 ]; then
    return 0
  else
    return 1
  fi
}

function docker_pull() {
  local image_name_tag="$1"
  docker pull $image_name_tag
  if [ $? -ne 0 ]; then
    log_error "migrate" "docker pull $from_image failed"
    exit 1
  fi
}

# 如果镜像存在，判断是否要再次pull
if image_exists $from_image; then
  # 判断是否要再次pull
  read -p "Image $from_image already exists, do you want to pull it again?[default: y] (y/n) :" answer
  if [ -z "$answer" ]; then
    answer="y"
  fi
  if [ "$answer" == "y" ]; then
    docker_pull $from_image
  fi
else
  log_info "migrate" "Image $from_image not found, pulling..."
  docker_pull $from_image
fi

# 再次判断镜像是否存在
if image_exists $from_image; then
  docker tag "$from_image" "$to_image"
  docker push "$to_image"
fi
