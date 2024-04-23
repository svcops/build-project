#!/bin/bash
# shellcheck disable=SC2086 disable=SC2155  disable=SC1090
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/command_exists.sh)

log "maven build" ">>> start <<<"
function end() {
  log "maven build" ">>> end <<<"
}

cache=""
image=""
build=""
build_dir=""
settings=""

function tips() {
  log "tips" "-d maven's build directory"
  log "tips" "-c user docker volume's to cache the build process"
  log "tips" "-i maven's docker image"
  log "tips" "-x maven's build command"
  log "tips" "-s maven's settings.xml path"
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

validate_param "cache" "$cache"
validate_param "image" "$image"
validate_param "build" "$build"
validate_param "settings" "$settings"

if [ -z "$build_dir" ]; then
  log "build_dir" "build_dir is empty then use current directory"
  build_dir="$(pwd)"
fi

if [[ $cache =~ ^[a-zA-Z0-9_.-]+$ ]]; then
  log "cache_str_validate" "cache str validate success"
else
  log "cache_str_validate" "cache str contains only English characters, digits, underscores, dots, and hyphens."
  log "cache_str_validate" "cache str validate failed"
  exit 1
fi

if [ ! -f $settings ]; then
  log "settings.xml" "settings.xml path error"
  exit 1
fi

if command_exists docker; then
  log "command_exists" "docker command exists"
else
  log "command_exists" "docker command does not exist"
  end
  exit 1
fi

log "build" "========== build maven's project in docker =========="

docker run -i --rm -u root \
  --network=host \
  -v "$build_dir":/usr/src/app \
  -w /usr/src/app \
  -v "$cache":/root/.m2/repository \
  -v "$settings":/usr/share/maven/ref/settings.xml \
  "$image" \
  $build

end
