#!/bin/bash
# shellcheck disable=SC2086 disable=SC2155  disable=SC1090
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/command_exists.sh)

log "node build" ">>> start <<<"
function end() {
  log "node build" ">>> end <<<"
}

image=""
build=""
build_dir=""

function tips() {
  log "tips" "-d node's build directory"
  log "tips" "-i node's docker image"
  log "tips" "-x node's build command"
}

while getopts ":i:x:d:" opt; do
  case ${opt} in
  d)
    log "get opts" "process's build_dir; build_dir is: $OPTARG"
    build_dir=$OPTARG
    ;;
  i)
    log "get opts" "process's image; docker's image is: $OPTARG"
    image=$OPTARG
    ;;
  x)
    log "get opts" "process's command; node's command is: $OPTARG"
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

validate_param "image" "$image"
validate_param "build" "$build"

if [ -z "$build_dir" ]; then
  log "build_dir" "build_dir is empty then use current directory"
  build_dir="$(pwd)"
elif [ ! -d "$build_dir" ]; then
  log "build_dir" "build_dir is not a valid paths"
  exit 1
fi

if command_exists docker; then
  log "command_exists" "docker command exists"
else
  log "command_exists" "docker command does not exist"
  end
  exit 1
fi

log "build" "========== build node's project in docker =========="

log "build" "docker run --rm -u root --network=host -v $build_dir:/opt/app/node  -w /opt/app/node $image $build"

docker run --rm -u root \
  --network=host \
  -v "$build_dir":/opt/app/node \
  -w /opt/app/node \
  "$image" \
  $build

end
