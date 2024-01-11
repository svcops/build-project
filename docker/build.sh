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
  local current_time
  current_time=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "$current_time - [ $log_remark ] $log_message"
}

command_exists() {
  # this should return the exit status of 'command -v'
  command -v "$1" >/dev/null 2>&1
}

log "docker build" ">>> docker build start <<<"
function end() {
  log "docker build" ">>> docker build end <<<"
}

registry=""
image_name=""
image_tag=""
re_tag_flag=""

function tips() {
  log "tips" "-m docker registry"
  log "tips" "-i docker image"
  log "tips" "-v docker tag"
  log "tips" "-r re tag flag"
}

while getopts ":m:i:v:r:" opt; do
  case ${opt} in
  m)
    log "getopts" "registry is: $OPTARG"
    registry=$OPTARG
    ;;
  i)
    log "getopts" "image name is : $OPTARG"
    image_name=$OPTARG
    ;;
  v)
    log "getopts" "image tag is : $OPTARG"
    image_tag=$OPTARG
    ;;
  r)
    log "getopts" "re tag flag is: $OPTARG"
    re_tag_flag=$OPTARG
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

validate_param "registry" "$registry"
validate_param "image_name" "$image_name"
validate_param "image_tag" "$image_tag"

if [ "$re_tag_flag" == "" ]; then
  re_tag_flag="true"
  log "re tag" "need re tag"
fi

function re_tag_push() {
  local image_exist=$(docker image ls $registry/$image_name | grep $image_tag | wc -l)
  if [ $image_exist -eq 1 ]; then
    log "re_tag_push" "image exists: $registry/$image_name:$image_tag"
    timestamp_tag=$(date '+%Y-%m-%d_%H-%M-%S')
    docker tag "$registry/$image_name:$image_tag" "$registry/$image_name:$timestamp_tag"
    log "re_tag_push" "re tag,then push: docker push $registry/$image_name:$timestamp_tag"
    docker push "$registry/$image_name:$timestamp_tag"
  else
    log "re_tag_push" "image does not exist: $registry/$image_name:$image_tag"
  fi
}

function build_push() {
  log "build_push" "docker build -f Dockerfile -t $registry/$image_name:$image_tag ."
  # 判断 Dockerfile是否存在
  if [ ! -f "Dockerfile" ]; then
    log "build_push" "Dockerfile does not exist exit"
    end
    exit 1
  fi
  docker build -f Dockerfile -t "$registry/$image_name:$image_tag" .
  log "build_push" "docker push $registry/$image_name:$image_tag"
  docker push "$registry/$image_name:$image_tag"
}

if command_exists docker; then
  log "command_exists" "docker command exists"
else
  log "command_exists" "docker command does not exist"
  end
  exit 1
fi

if [ "$re_tag_flag" == "true" ]; then
  log "docker tag" "need re tag"
  re_tag_push
  build_push
else
  log "docker tag" "do need re tag"
  build_push
fi

end
