#!/bin/bash
# shellcheck disable=SC2086
# shellcheck disable=SC2046
# shellcheck disable=SC2126
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

log "docker rmi" ">>> docker rmi start <<<"
function end() {
  log "docker rmi" ">>> docker rmi end <<<"
}

command_exists() {
  # this should return the exit status of 'command -v'
  command -v "$1" >/dev/null 2>&1
}

function tips() {
  log "tips" "-i image name"
  log "tips" "-s strategy: contain_latest remove_none all"
}

title_reg="^REPOSITORY\s*TAG\s*IMAGE\s*\ID\s*CREATED\s*SIZE$"

image_name=""
strategy=""

while getopts ":i:s:" opt; do
  case ${opt} in
  i)
    log "getopts" "image name is : $OPTARG"
    image_name=$OPTARG
    ;;
  s)
    log "getopts" "remove strategy is : $OPTARG"
    strategy=$OPTARG
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

validate_param "image_name" "$image_name"

if [ -z "$strategy" ]; then
  log "strategy" "strategy is empty use default contain_latest"
  strategy="contain_latest"
fi

if command_exists docker; then
  log "command_exists" "docker command exists"
else
  log "command_exists" "docker command does not exist"
  end
  exit 1
fi

if [ "$strategy" == "contain_latest" ]; then

  con=$(docker image ls $image_name | grep -v $title_reg | grep -v "latest" | wc -l)

  if [ $con -eq 0 ]; then
    log "contain_latest" "image doesn't exit ,then exit"
    end
    exit
  fi

  docker image rm -f $(docker image ls $image_name | grep -v $title_reg | grep -v "latest" | awk '{print $3}')

elif [ "$strategy" == "remove_none" ]; then

  con=$(docker image ls $image_name | grep -v $title_reg | grep "<none>" | wc -l)
  if [ $con -eq 0 ]; then
    log "remove_none" "image doesn't exit ,then exit"
    end
    exit
  fi

  docker image rm -f $(docker image ls $image_name | grep -v $title_reg | grep "<none>" | awk '{print $3}')

elif [ "$strategy" == "all" ]; then

  con=$(docker image ls $image_name | grep -v $title_reg | wc -l)

  if [ $con -eq 0 ]; then
    log "all" "image doesn't exit ,then exit"
    end
    exit
  fi

  docker image rm -f $(docker image ls $image_name | grep -v $title_reg | awk '{print $3}')

fi

end
