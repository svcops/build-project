#!/bin/bash
# shellcheck disable=SC2086 disable=SC2046 disable=SC2126 disable=SC2155 disable=SC1090
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/command_exists.sh)

log "docker rmi" ">>> docker rmi start <<<"
function end() {
  log "docker rmi" ">>> docker rmi end <<<"
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
    log "get opts" "image name is : $OPTARG"
    image_name=$OPTARG
    ;;
  s)
    log "get opts" "remove strategy is : $OPTARG"
    strategy=$OPTARG
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
