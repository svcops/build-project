#!/bin/bash
# shellcheck disable=SC2086 disable=SC2155  disable=SC1090
source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
# ROOT_URI=https://dev.kubectl.net

source <(curl -SL $ROOT_URI/func/log.sh)
source <(curl -SL $ROOT_URI/func/command_exists.sh)

log_info "gradle build" ">>> start <<<"
function end() {
  log_info "gradle build" ">>> end <<<"
}

cache=""
image=""
build=""
build_dir=""

function tips() {
  log_info "tips" "-d gradle's build directory"
  log_info "tips" "-c user docker volume's to cache the build process"
  log_info "tips" "-i gradle's docker image"
  log_info "tips" "-x gradle's build command"
}

while getopts ":c:i:x:d:" opt; do
  case ${opt} in
  d)
    log_info "get opts" "process's build_dir; build_dir is: $OPTARG"
    build_dir=$OPTARG
    ;;
  c)
    log_info "get opts" "process's cache; docker's volume is: $OPTARG"
    cache=$OPTARG
    ;;
  i)
    log_info "get opts" "process's image; docker's image is: $OPTARG"
    image=$OPTARG
    ;;
  x)
    log_info "get opts" "process's command; gradle's command is: $OPTARG"
    build=$OPTARG
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

function validate_not_blank() {
  local key=$1
  local value=$2
  if [ -z "$value" ]; then
    log_error "validate_not_blank" "parameter $key is empty, then exit"
    tips
    end
    exit 1
  else
    log_info "validate_not_blank" "parameter $key : $value"
  fi
}

validate_not_blank "cache" "$cache"
validate_not_blank "image" "$image"
validate_not_blank "build" "$build"

if [ -z "$build_dir" ]; then
  log_warn "build_dir" "build_dir is empty then use current directory"
  build_dir="$(pwd)"
elif [ ! -d "$build_dir" ]; then
  log_error "build_dir" "build_dir is not a valid paths"
  exit 1
fi

if [[ $cache =~ ^[a-zA-Z0-9_.-]+$ ]]; then
  log_info "cache_str_validate" "cache str validate success"
else
  log_error "cache_str_validate" "cache str contains only English characters, digits, underscores, dots, and hyphens."
  log_error "cache_str_validate" "cache str validate failed"
  exit 1
fi

if command_exists docker; then
  log_info "command_exists" "docker command exists"
else
  log_error "command_exists" "docker command does not exist"
  end
  exit 1
fi

log_info "build" "========== build gradle's project in docker =========="

docker run --rm -u root \
  --network=host \
  -v "$build_dir":/home/gradle/project \
  -w /home/gradle/project \
  -v "$cache:/home/gradle/.gradle" \
  "$image" \
  $build

end
