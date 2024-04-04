#!/bin/bash
# shellcheck disable=SC1090
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/command_exists.sh)

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
  log "tips" "-i the name of the image to be built"
  log "tips" "-v the tag of the image to be built"
  log "tips" "-r re tag flag, default <true>"
  log "tips" "-t the new_tag of the image to be built. if empty, use timestamp_tag."
  log "tips" "-p push flag, default <false>"
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

function print_param() {
  log "print" "path_to_dockerfile: $path_to_dockerfile"
  log "print" "image_name: $image_name"
  log "print" "image_tag: $image_tag"
  log "print" "re_tag_flag: $re_tag_flag"
  log "print" "new_tag: $new_tag"
  log "print" "push_flag: $push_flag"
}
print_param

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

function validate_docker_tag() {
  if echo "$1" | grep -Eq "^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,127}$"; then
    # echo "Valid"
    log "validate_docker_tag" "$1 is Valid"
    return 0
  else
    # echo "Invalid"
    log "validate_docker_tag" "$1 is Invalid"
    return 1
  fi
}

function prepare_validate() {
  validate_param "image_name" "$image_name"
  validate_param "image_tag" "$image_tag"
  if ! validate_docker_tag "$image_tag"; then
    exit
  fi
}

# 准备验证
prepare_validate

# --- 处理是否需要重新打标签

if [ "$re_tag_flag" == "true" ]; then
  re_tag_flag="true"
  log "re tag" "need re tag"
else
  re_tag_flag="false"
  log "re tag" "do not need re tag"
fi

# 如果需要重新tag,验证新的tag
timestamp_tag=$(date '+%Y-%m-%d_%H-%M-%S')
function validate_new_tag() {
  log "validate_new_tag" "validate_new_tag"

  if [ -z "$new_tag" ]; then
    # 需要 re_tag 的时候, 传入的 new_tag 为空, 默认使用 timestamp_tag
    log "validate_new_tag" "new tag is empty ,will use timestamp_tag"
    new_tag=$timestamp_tag
  elif validate_docker_tag "$new_tag"; then
    # 传入的 new_tag 不符合docker tag 规范
    log "validate_new_tag" "new tag is Invalid"
    exit 1
  elif [ "$new_tag" == "$image_tag" ]; then
    # 新的标签的docker build 的标签相同，验证不通过，exit
    log "validate_new_tag" "validate failed , because new_tag == image_tag "
    end
    exit 1
  else
    # new tag
    # 新的tag的镜像在 docker image ls 中存在，使用 timestamp_tag
    if docker image ls "$image_name" | grep -q -E "\b$new_tag\b"; then
      log "validate_new_tag" "$image_name:$new_tag has existed,then use timestamp_tag"
      new_tag=$timestamp_tag
    fi
  fi
}

if [ "$re_tag_flag" == "true" ]; then
  validate_new_tag
fi

# ---
if [ "$push_flag" == "true" ]; then
  push_flag="true"
  log "push flag" "push_flag is true"
else
  push_flag="false"
  log "push flag" "push_flag is false"
fi

function re_tag_push() {

  if docker image ls "$image_name" | grep -q -E "\b$image_tag\b"; then
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
if [ -z "$path_to_dockerfile" ]; then # path_to_dockerfile is empty
  log "dockerfile" "path_to_dockerfile is empty, try use default (DOCKERFILE or Dockerfile or dockerfile)"
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
elif [ ! -f "$path_to_dockerfile" ]; then # path_to_dockerfile is not empty
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
