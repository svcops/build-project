#!/bin/bash
# shellcheck disable=SC2086 disable=SC2046 disable=SC2126 disable=SC2155 disable=SC1090 disable=SC2028
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh) && export ROOT_URI=$ROOT_URI
# ROOT_URI=https://dev.kubectl.net

source <(curl -sSL $ROOT_URI/func/log.sh)
source <(curl -sSL $ROOT_URI/func/command_exists.sh)

log "docker rmi" ">>> docker rmi start <<<"
function end() {
  log "docker rmi" ">>> docker rmi end <<<"
}

function tips() {
  log_info "tips" "-i image name"
  log_info "tips" "-s strategy: contain_latest remove_none all"
}

title_reg="^REPOSITORY\s*TAG\s*IMAGE\s*\ID\s*CREATED\s*SIZE$"

image_name=""
strategy=""

while getopts ":i:s:" opt; do
  case ${opt} in
  i)
    log_info "get opts" "image name is : $OPTARG"
    image_name=$OPTARG
    ;;
  s)
    log_info "get opts" "remove strategy is : $OPTARG"
    strategy=$OPTARG
    ;;
  \?)
    log_error "get opts" "Invalid option: -$OPTARG"
    tips
    end
    exit 1
    ;;
  :)
    log_info "get opts" "Invalid option: -$OPTARG requires an argument"
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

validate_param "image_name" "$image_name"

if [ -z "$strategy" ]; then
  log_warn "strategy" "strategy is empty use default contain_latest"
  strategy="contain_latest"
fi

if command_exists docker; then
  log_info "command_exists" "docker command exists"
else
  log_error "command_exists" "docker command does not exist"
  end
  exit 1
fi

if [ "$strategy" == "contain_latest" ]; then

  con=$(docker image ls $image_name | grep -v $title_reg | grep -v "latest" | wc -l)

  if [ $con -eq 0 ]; then
    log_warn "contain_latest" "image doesn't exit ,then exit"
    end
    exit
  fi

  docker image rm -f $(docker image ls $image_name | grep -v $title_reg | grep -v "latest" | awk '{print $3}')

elif [ "$strategy" == "remove_none" ]; then

  con=$(docker image ls $image_name | grep -v $title_reg | grep "<none>" | wc -l)

  if [ $con -eq 0 ]; then
    log_info "remove_none" "image doesn't exit ,then exit"
    end
    exit
  fi

  docker image rm -f $(docker image ls $image_name | grep -v $title_reg | grep "<none>" | awk '{print $3}')

elif [ "$strategy" == "all" ]; then

  con=$(docker image ls $image_name | grep -v $title_reg | wc -l)

  if [ $con -eq 0 ]; then
    log_info "all" "image doesn't exit ,then exit"
    end
    exit
  fi

  docker image rm -f $(docker image ls $image_name | grep -v $title_reg | awk '{print $3}')

fi

end
