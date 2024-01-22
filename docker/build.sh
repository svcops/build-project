#!/bin/bash
# shellcheck disable=SC2086 disable=SC2155 disable=SC2126 disable=SC1090

source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)

command_exists() {
  # this should return the exit status of 'command -v'
  command -v "$1" >/dev/null 2>&1
}

log "docker build" ">>> docker build start <<<"
function end() {
  log "docker build" ">>> docker build end <<<"
}

image_name=""
image_tag=""
re_tag_flag=""
new_tag=""
push_flag=""

function tips() {
  log "tips" "-i docker's image"
  log "tips" "-v docker's tag"
  log "tips" "-r re tag flag default tag version is "
  log "tips" "-t docker's new tag"
  log "tips" "-p push flag"
}

while getopts ":i:v:r:t:p:" opt; do
  case ${opt} in
  i)
    log "get opts" "image name is : $OPTARG"
    image_name=$OPTARG
    ;;
  v)
    log "get opts" "image tag is : $OPTARG"
    image_tag=$OPTARG
    ;;
  r)
    log "get opts" "re tag flag is: $OPTARG"
    re_tag_flag=$OPTARG
    ;;
  t)
    log "get opts" "new tag is: $OPTARG"
    new_tag=$OPTARG
    ;;
  p)
    log "get opts" "push flag is: $OPTARG"
    push_flag=$OPTARG
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
validate_param "image_tag" "$image_tag"

if [ "$re_tag_flag" == "" ]; then
  re_tag_flag="true"
  log "re tag" "need re tag"
fi

function validate_new_tag() {
  log "validate_new_tag" "validate_new_tag"
  if [ "$re_tag_flag" == "true" ]; then
    # 验证不为空
    validate_param "new_tag" "$new_tag"
    if [ "$new_tag" == "$image_tag" ]; then
      log "validate_new_tag" "validate failed , because new_tag == image_tag "
      end
      exit 1
    else
      # new tag
      local image_exist=$(docker image ls $image_name | grep $new_tag | wc -l)
      if [ $image_exist -eq 1 ]; then
        log "validate_new_tag" "$image_name:$new_tag has existed,then use timestamp_tag"
        local timestamp_tag=$(date '+%Y-%m-%d_%H-%M-%S')
        new_tag=$timestamp_tag
      fi
    fi
  fi

}

validate_new_tag

if [ "$push_flag" == "" ]; then
  push_flag="false"
  log "push flag" "push flag default is false"
fi

function re_tag_push() {
  local image_exist=$(docker image ls $image_name | grep $image_tag | wc -l)

  if [ $image_exist -eq 1 ]; then
    log "re_tag_push" "image exists: $image_name:$image_tag"
    docker tag "$image_name:$image_tag" "$image_name:$new_tag"

    if [ "$push_flag" == "true" ]; then
      log "re_tag_push" "re tag,then push: docker push $image_name:$new_tag"
      docker push "$image_name:$new_tag"
    fi

  else
    log "re_tag_push" "image does not exist: $image_name:$image_tag"
  fi
}

function build_push() {
  log "build_push" "docker build -f Dockerfile -t $image_name:$image_tag ."
  # 判断 Dockerfile是否存在
  if [ ! -f "Dockerfile" ]; then
    log "build_push" "Dockerfile does not exist exit"
    end
    exit 1
  fi

  docker build -f Dockerfile -t "$image_name:$image_tag" .
  log "build_push" "docker push $image_name:$image_tag"

  if [ "$push_flag" == "true" ]; then
    docker push "$image_name:$image_tag"
  fi
}

if command_exists docker; then
  log "command_exists" "docker command exists"
else
  log "command_exists" "docker command does not exist"
  end
  exit 1
fi

# docker pull $image_name:$image_tag

if [ "$re_tag_flag" == "true" ]; then
  log "docker tag" "do re_tag_push and build_push"
  re_tag_push
  build_push
else
  log "docker tag" "do build_push"
  build_push
fi

end
