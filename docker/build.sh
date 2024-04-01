#!/bin/bash
# shellcheck disable=SC2086 disable=SC2155 disable=SC2126 disable=SC1090 disable=SC2164
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/command_exists.sh)

log "docker build" ">>> docker build start <<<"
function end() {
  log "docker build" ">>> docker build end <<<"
}

path_to_dockerfile=""
image_name=""
image_tag=""
re_tag_flag=""
new_tag=""
push_flag=""

function tips() {
  log "tips" "-f path/to/dockerfile, optional"
  log "tips" "-i docker's image"
  log "tips" "-v docker's tag"
  log "tips" "-r re tag flag default tag version is timestamp_tag"
  log "tips" "-t docker's new tag"
  log "tips" "-p push flag, default false"
}

while getopts ":f:i:v:r:t:p:" opt; do
  case ${opt} in
  f)
    log "get opts" "path_to_dockerfile is : $OPTARG"
    path_to_dockerfile=$OPTARG
    ;;
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

# ---

if [ "$re_tag_flag" == "" ]; then
  re_tag_flag="true"
  log "re tag" "need re tag"
fi

function validate_new_tag() {
  log "validate_new_tag" "validate_new_tag"
  # 验证不为空
  validate_param "new_tag" "$new_tag"
  if [ "$new_tag" == "$image_tag" ]; then
    log "validate_new_tag" "validate failed , because new_tag == image_tag "
    end
    exit 1
  elif [ -z "$new_tag" ]; then
    log "validate_new_tag" "new tag is empty use timestamp_tag"
    new_tag=$timestamp_tag
  else
    # new tag
    local image_exist=$(docker image ls $image_name | grep $new_tag | wc -l)
    if [ $image_exist -eq 1 ]; then
      log "validate_new_tag" "$image_name:$new_tag has existed,then use timestamp_tag"
      local timestamp_tag=$(date '+%Y-%m-%d_%H-%M-%S')
      new_tag=$timestamp_tag
    fi
  fi
}

if [ "$re_tag_flag" == "true" ]; then
  validate_new_tag
fi

# ---
if [ "$push_flag" == "" ]; then
  push_flag="false"
  log "push flag" "Default push flag is false"
fi

function re_tag_push() {
  local image_exist=$(docker image ls $image_name | grep $image_tag | wc -l)

  if [ $image_exist -eq 1 ]; then
    log "re_tag" "image exists: $image_name:$image_tag"
    docker tag "$image_name:$image_tag" "$image_name:$new_tag"

    if [ "$push_flag" == "true" ]; then
      log "re_tag_push" "docker push $image_name:$new_tag"
      docker push "$image_name:$new_tag"
    fi

  else
    log "re_tag_push" "image does not exist: $image_name:$image_tag"
  fi
}

# ---
if [ -z "$path_to_dockerfile" ]; then
  log "dockerfile" "path_to_dockerfile is empty, try use default (DOCKERFILE or Dockerfile or dockerfile)"
  # -f 参数为空
  if [ -f "DOCKERFILE" ]; then
    path_to_dockerfile="DOCKERFILE"
  elif [ -f "Dockerfile" ]; then
    path_to_dockerfile="Dockerfile"
  elif [ -f "dockerfile" ]; then
    path_to_dockerfile="dockerfile"
  else
    log "dockerfile" "Default Dockerfile does not exit; (DOCKERFILE or Dockerfile or dockerfile)"
    end
    exit 1
  fi
elif [ ! -f "$path_to_dockerfile" ]; then
  # -f 参数不为空
  log "build_push" "Dockerfile does not exist exit"
  end
  exit 1
fi

# 获取dockerfile的目录和文件名称
DOCKERFILE_FOLDER=$(cd "$(dirname "$path_to_dockerfile")" && pwd)
DOCKERFILE_NAME=$(basename $path_to_dockerfile)

log "dockerfile" "DOCKERFILE_FOLDER : $DOCKERFILE_FOLDER; DOCKERFILE_NAME : $DOCKERFILE_NAME"

function build_push() {

  log "docker_build" "docker build -f $path_to_dockerfile -t $image_name:$image_tag $DOCKERFILE_FOLDER"
  docker build -f "$path_to_dockerfile" -t "$image_name:$image_tag" "$DOCKERFILE_FOLDER"

  if [ "$push_flag" == "true" ]; then
    log "build_push" "docker push $image_name:$image_tag"
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
