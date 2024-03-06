#!/bin/bash
# shellcheck disable=SC2086 disable=SC2155  disable=SC1090
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/command_exists.sh)

log "gradle build" ">>> start <<<"
function end() {
  log "gradle build" ">>> end <<<"
}

cache=""
image=""
build=""

function tips() {
  log "tips" "-c user docker volume's to cache the build process"
  log "tips" "-i gradle's docker image"
  log "tips" "-x gradle's build command"
}

while getopts ":c:i:x:" opt; do
  case ${opt} in
  c)
    log "get opts" "process's cache; docker's volume is: $OPTARG"
    cache=$OPTARG
    ;;
  i)
    log "get opts" "process's image; docker's image is: $OPTARG"
    image=$OPTARG
    ;;
  x)
    log "get opts" "process's command; gradle's command is: $OPTARG"
    build=$OPTARG
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

if [[ $cache =~ ^[a-zA-Z0-9_.-]+$ ]]; then
  log "cache_str_validate" "cache str validate success"
else
  log "cache_str_validate" "cache str contains only English characters, digits, underscores, dots, and hyphens."
  log "cache_str_validate" "cache str validate failed"
  exit 1
fi

if command_exists docker; then
  log "command_exists" "docker command exists"
else
  log "command_exists" "docker command does not exist"
  end
  exit 1
fi

log "build" "========== build gradle's project in docker =========="

docker run --rm -u root \
  --network=host \
  -v "$PWD":/home/gradle/project \
  -w /home/gradle/project \
  -v "$cache:/home/gradle/.gradle" \
  "$image" \
  $build

end
