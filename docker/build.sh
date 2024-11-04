#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086
# source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
ROOT_URI=https://code.kubectl.net/devops/build-project/raw/branch/main

source <(curl -SL $ROOT_URI/func/log.sh)
source <(curl -SL $ROOT_URI/func/command_exists.sh)

log_info "docker build" ">>> docker build start <<<"
function end() {
  log_info "docker build" ">>> docker build end <<<"
}

multi_platform=""
path_to_dockerfile=""
build_dir=""
image_name=""
image_tag=""
re_tag_flag=""
new_tag=""
push_flag=""
build_args=()

unset build_args

function tips() {
  log_info "tips" "-m multi platform(amd64 arm64), optional"
  log_info "tips" "-d build directory, optional if empty,use Dockerfile's directory"
  log_info "tips" "-f path/to/dockerfile, optional"
  log_info "tips" "-i the name of the image to be built"
  log_info "tips" "-v the tag of the image to be built"
  log_info "tips" "-r re tag flag, default <true>"
  log_info "tips" "-t the new_tag of the image to be built. if empty, use timestamp_tag."
  log_info "tips" "-p push flag, default <false>"
  log_info "tips" "-a build arg, stringArray. Set build-time variables"
}

while getopts ":m:f:d:i:v:r:t:p:a:" opt; do
  case ${opt} in
  m)
    log_info "get opts" "multi_platform is : $OPTARG"
    multi_platform=$OPTARG
    ;;
  d)
    log_info "get opts" "build_dir is : $OPTARG"
    build_dir=$OPTARG
    ;;
  f)
    log_info "get opts" "path_to_dockerfile is : $OPTARG"
    path_to_dockerfile=$OPTARG
    ;;
  i)
    log_info "get opts" "image name is : $OPTARG"
    image_name=$OPTARG
    ;;
  v)
    log_info "get opts" "image tag is : $OPTARG"
    image_tag=$OPTARG
    ;;
  r)
    log_info "get opts" "re tag flag is: $OPTARG"
    re_tag_flag=$OPTARG
    ;;
  t)
    log_info "get opts" "new tag is: $OPTARG"
    new_tag=$OPTARG
    ;;
  p)
    log_info "get opts" "push flag is: $OPTARG"
    push_flag=$OPTARG
    ;;
  a)
    log_info "get opts" "build arg is: $OPTARG"
    build_args+=("$OPTARG")
    ;;
  \?)
    log_info "get opts" "Invalid option: -$OPTARG"
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

function print_param() {
  log_info "print" "path_to_dockerfile: $path_to_dockerfile"
  log_info "print" "image_name: $image_name"
  log_info "print" "image_tag: $image_tag"
  log_info "print" "re_tag_flag: $re_tag_flag"
  log_info "print" "new_tag: $new_tag"
  log_info "print" "push_flag: $push_flag"
  for build_arg in "${build_args[@]}"; do
    log_info "print" "build_args: $build_arg"
  done
}

print_param

function do_validate() {

  function validate_param() {
    local key=$1
    local value=$2
    if [ -z "$value" ]; then
      log_error "validate_param" "parameter $key is empty, then exit"
      tips
      end
      exit 1
    else
      log_info "validate_param" "parameter $key : $value"
    fi
  }

  function validate_build_args() {
    local v=$1
    for build_arg in "${v[@]}"; do
      log_info "validate_build_args" "todo..."
    done
  }

  function validate_docker_tag() {
    if echo "$1" | grep -Eq "^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,127}$"; then
      # echo "Valid"
      # log "validate_docker_tag" "$1 is Valid"
      return 0
    else
      # echo "Invalid"
      # log "validate_docker_tag" "$1 is Invalid"
      return 1
    fi
  }

  function prepare_validate() {
    validate_param "image_name" "$image_name"
    validate_param "image_tag" "$image_tag"
    # shellcheck disable=SC2128
    validate_build_args $build_args
    if ! validate_docker_tag "$image_tag"; then
      exit
    fi
  }

  # 准备验证
  prepare_validate
}
do_validate

# --build-arg foo=bar ...
function prepare_build_args_exec() {
  build_args_exec=""
  for build_arg in "${build_args[@]}"; do
    build_args_exec="$build_args_exec --build-arg $build_arg"
  done
  log_info "build_args_exec" "$build_args_exec"
}

prepare_build_args_exec

# --- 处理是否需要重新打标签
function prepare_tags() {
  if [ "$re_tag_flag" == "true" ]; then
    re_tag_flag="true"
    log_info "re tag" "need re tag"
  else
    re_tag_flag="false"
    log_info "re tag" "do not need re tag"
  fi

  # 如果需要重新tag,验证新的tag
  timestamp_tag=$(date '+%Y-%m-%d_%H-%M-%S')
  function validate_new_tag() {
    log_info "validate_new_tag" "validate_new_tag"

    if [ -z "$new_tag" ]; then
      # 需要 re_tag 的时候, 传入的 new_tag 为空, 默认使用 timestamp_tag
      log_info "validate_new_tag" "new tag is empty ,will use timestamp_tag"
      new_tag=$timestamp_tag
    elif ! validate_docker_tag "$new_tag"; then
      # 传入的 new_tag 不符合docker tag 规范
      log_error "validate_new_tag" "new tag [$new_tag] is Invalid"
      exit 1
    elif [ "$new_tag" == "$image_tag" ]; then
      # 新的标签的docker build 的标签相同，验证不通过，exit
      log_error "validate_new_tag" "validate failed , because new_tag == image_tag "
      end
      exit 1
    else
      # new tag
      # 新的tag的镜像在 docker image ls 中存在，使用 timestamp_tag
      if docker image ls "$image_name" | grep -q -E "\b$new_tag\b"; then
        log_info "validate_new_tag" "$image_name:$new_tag has existed,then use timestamp_tag"
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
}

prepare_tags

# ---
function prepare_dockerfile_and_build_dir() {
  if [ -z "$path_to_dockerfile" ]; then # path_to_dockerfile is empty
    log_info "dockerfile" "path_to_dockerfile is empty, try use default (DOCKERFILE or Dockerfile or dockerfile)"
    if [ -f "DOCKERFILE" ]; then
      path_to_dockerfile="DOCKERFILE"
    elif [ -f "Dockerfile" ]; then
      path_to_dockerfile="Dockerfile"
    elif [ -f "dockerfile" ]; then
      path_to_dockerfile="dockerfile"
    else
      log_error "dockerfile" "Default Dockerfile does not exit; (DOCKERFILE or Dockerfile or dockerfile)"
      end
      exit 1
    fi
  elif [ -f "$path_to_dockerfile" ]; then
    log_info "dockerfile" "detect dockerfile: $path_to_dockerfile"
  else
    log_error "build_push" "Dockerfile does not exist exit"
    end
    exit 1
  fi

  # 获取dockerfile的目录和文件名称
  build_dir_default=$(cd "$(dirname "$path_to_dockerfile")" && pwd)
  #  DOCKERFILE=$(basename $path_to_dockerfile)

  if [ -z "$build_dir" ]; then
    log_info "build_dir" "build_dir is empty then use DOCKER_BUILD_DIR"
    build_dir="$build_dir_default"
  elif [ ! -d "$build_dir" ]; then
    log_error "build_dir" "build_dir is not a valid paths"
    exit 1
  fi

  log_info "dockerfile" "docker build dir : $build_dir_default; dockerfile : $path_to_dockerfile"
}
prepare_dockerfile_and_build_dir

if [ "$multi_platform" == "true" ]; then
  log_info "multi_platform" "use docker buildx"
  multi_platform="true"
else
  log_info "multi_platform" "use docker build"
  multi_platform="false"
fi

# build and push
function build_push() {
  if [ "$multi_platform" == "true" ]; then
    #    log "docker_build" "docker buildx build --platform linux/amd64,linux/arm64 $path_to_dockerfile -t $image_name:$image_tag $build_dir"
    #    docker buildx build --platform linux/amd64,linux/arm64 "$path_to_dockerfile" -t "$image_name:$image_tag" "$build_dir"
    log_info "docker_build" "docker build -f $path_to_dockerfile $build_args_exec -t $image_name:$image_tag $build_dir"
    docker build -f "$path_to_dockerfile" $build_args_exec -t "$image_name:$image_tag" "$build_dir"
  else
    log_info "docker_build" "docker build -f $path_to_dockerfile $build_args_exec -t $image_name:$image_tag $build_dir"
    docker build -f "$path_to_dockerfile" $build_args_exec -t "$image_name:$image_tag" "$build_dir"
  fi

  local build_status=$?
  if [ $build_status -eq 0 ]; then
    log_info "docker_build" "Docker build succeeded"
  else
    log_error "docker_build" "Docker build failed"
    exit 1
  fi

  if [ "$push_flag" == "true" ]; then
    log_info "build_push" "docker push $image_name:$image_tag"
    docker push "$image_name:$image_tag"
  fi

}

# re tag and push
function re_tag_push() {
  if docker image ls "$image_name" | grep -q -E "\b$image_tag\b"; then
    log_info "re_tag" "image exists: $image_name:$image_tag"
    docker tag "$image_name:$image_tag" "$image_name:$new_tag"

    if [ "$push_flag" == "true" ]; then
      log_info "re_tag_push" "docker push $image_name:$new_tag"
      docker push "$image_name:$new_tag"
    fi

  else
    log_info "re_tag_push" "image does not exist: $image_name:$image_tag"
  fi
}

if command_exists docker; then
  log_info "command_exists" "docker command exists"
else
  log_error "command_exists" "docker command does not exist"
  end
  exit 1
fi

# docker pull $image_name:$image_tag
function do_build() {
  if [ "$re_tag_flag" == "true" ]; then
    log_info "docker tag" "do re_tag_push and build_push"
    re_tag_push
    build_push
  else
    log_info "docker tag" "do build_push"
    build_push
  fi
}
do_build

end
