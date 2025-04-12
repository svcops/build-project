#!/bin/bash
# shellcheck disable=SC2086 disable=SC2155  disable=SC1090 disable=SC2028
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
echo -e "\033[0;32mROOT_URI=$ROOT_URI\033[0m"
# ROOT_URI=https://dev.kubectl.net

source <(curl -sSL $ROOT_URI/func/log.sh)
source <(curl -sSL $ROOT_URI/func/ostype.sh)
source <(curl -sSL $ROOT_URI/func/command_exists.sh)

log_info "maven build" ">>> start <<<"
function end() {
  log_info "maven build" ">>> end <<<"
}

cache=""
image=""
build=""
build_dir=""
settings=""

function tips() {
  log_info "tips" "-d maven's build directory"
  log_info "tips" "-c user docker volume's to cache the build process"
  log_info "tips" "-i maven's docker image"
  log_info "tips" "-x maven's build command"
  log_info "tips" "-s maven's settings.xml path"
}

while getopts ":c:i:x:s:d:" opt; do
  case ${opt} in
  d)
    log "get opts" "process's build_dir; build_dir is: $OPTARG"
    build_dir=$OPTARG
    ;;
  c)
    log "get opts" "process's cache; docker's volume is: $OPTARG"
    cache=$OPTARG
    ;;
  i)
    log "get opts" "process's image; docker's image is: $OPTARG"
    image=$OPTARG
    ;;
  x)
    log "get opts" "process's command; maven's command is: $OPTARG"
    build=$OPTARG
    ;;
  s)
    log "get opts" "process's settings; maven's settings.xml is: $OPTARG"
    settings=$OPTARG
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

function validate_not_blank() {
  local key=$1
  local value=$2
  if [ -z "$value" ]; then
    log_info "validate_not_blank" "parameter $key is empty, then exit"
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
validate_not_blank "settings" "$settings"

if [ -z "$build_dir" ]; then
  log_info "build_dir" "build_dir is empty then use current directory"
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

if [ ! -f $settings ]; then
  log_error "settings.xml" "settings.xml path error"
  exit 1
fi

if command_exists docker; then
  log_info "command_exists" "docker command exists"
else
  log_error "command_exists" "docker command does not exist"
  end
  exit 1
fi

log_info "build" "========== build maven's project in docker =========="
# 判断是不是windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  log_info "windows" "windows system"
  # 在脚本开头或 Docker 命令前添加
  export MSYS_NO_PATHCONV=1
  docker run -i --rm -u root \
    -v "$build_dir:/usr/src/app" \
    -w "/usr/src/app" \
    -v "$cache:/root/.m2/repository" \
    -v "$settings:/usr/share/maven/ref/settings.xml" \
    "$image" \
    $build
else
  log_info "linux" "linux system"
  docker run -i --rm -u root \
    --network host \
    -v "$build_dir:/usr/src/app" \
    -w "/usr/src/app" \
    -v "$cache:/root/.m2/repository" \
    -v "$settings:/usr/share/maven/ref/settings.xml" \
    "$image" \
    $build
fi

end
