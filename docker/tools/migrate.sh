#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086 disable=SC2155 disable=SC2128 disable=SC2028 disable=SC2181 disable=SC2046
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
echo -e "\033[0;32mROOT_URI=$ROOT_URI\033[0m"
# ROOT_URI=https://dev.kubectl.net

source <(curl -SL $ROOT_URI/func/log.sh)
source <(curl -SL $ROOT_URI/func/command_exists.sh)

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

docker pull "$from_image"
if [ $? -ne 0 ]; then
  log_error "migrate" "docker pull $from_image failed"
  exit 1
fi

if [ $(docker image ls $from_image | wc -l) -ge 2 ]; then
  log_info "migrate" "docker pull $from_image success"
else
  log_error "migrate" "docker pull $from_image failed"
  exit 1
fi
docker tag "$from_image" "$to_image"
docker push "$to_image"
