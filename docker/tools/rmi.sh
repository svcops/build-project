#!/bin/bash
# shellcheck disable=SC2086 disable=SC2046 disable=SC2126 disable=SC2155 disable=SC1090 disable=SC2028
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh) && export ROOT_URI=$ROOT_URI
# ROOT_URI=https://dev.kubectl.net

source <(curl -sSL $ROOT_URI/func/log.sh)

log "docker rmi" ">>> docker rmi start <<<"
function end() {
  log "docker rmi" ">>> docker rmi end <<<"
}

function show_usage() {
  echo "Usage: rmi.sh -i <image_name> [-s <strategy>]"
  echo "Options:"
  echo "  -i <image_name>   Specify the name of the Docker image to clean."
  echo "  -s <strategy>     Specify the removal strategy (contain_latest, remove_none, all). Default is contain_latest."
  echo "Example:"
  echo "  rmi.sh -i my_image -s contain_latest"
  end
}

declare -g image_name=""
declare -g strategy=""

function parse_params() {
  while getopts ":i:s:" opt; do
    case ${opt} in
    i)
      log_info "get opts" "image name is : $OPTARG"
      image_name=$OPTARG
      ;;
    s)
      log_info "get opts" "remove strategy is : $OPTARG"
      strategy=$OPTARG
      ;;
    \?)
      log_error "get opts" "Invalid option: -$OPTARG"
      show_usage
      end
      exit 1
      ;;
    :)
      log_info "get opts" "Invalid option: -$OPTARG requires an argument"
      show_usage
      end
      exit 1
      ;;
    esac
  done
}

function validate_params() {
  if [ -z "$image_name" ]; then
    log_error "validate_param" "parameter image_name is empty, then exit"
    show_usage
    end
    exit 1
  else
    log_info "validate_param" "parameter image_name : $image_name"
  fi

  if [ -z "$strategy" ]; then
    log_warn "strategy" "strategy is empty use default contain_latest"
    strategy="contain_latest"
  fi
}

function clean_image() {

  local title_reg="^REPOSITORY\s*TAG\s*IMAGE\s*\ID\s*CREATED\s*SIZE$"

  if [ "$strategy" == "contain_latest" ]; then
    con=$(docker image ls $image_name | grep -v $title_reg | grep -v "latest" | wc -l)
    if [ $con -eq 0 ]; then
      log_warn "contain_latest" "image doesn't exit ,then exit"
      end
      exit
    fi
    docker image rm -f $(docker image ls $image_name | grep -v $title_reg | grep -v "latest" | awk '{print $3}')
  elif [ "$strategy" == "remove_none" ]; then
    con=$(docker image ls $image_name | grep -v $title_reg | grep "<none>" | wc -l)
    if [ $con -eq 0 ]; then
      log_info "remove_none" "image doesn't exit ,then exit"
      end
      exit
    fi
    docker image rm -f $(docker image ls $image_name | grep -v $title_reg | grep "<none>" | awk '{print $3}')
  elif [ "$strategy" == "all" ]; then
    con=$(docker image ls $image_name | grep -v $title_reg | wc -l)
    if [ $con -eq 0 ]; then
      log_info "all" "image doesn't exit ,then exit"
      end
      exit
    fi
    docker image rm -f $(docker image ls $image_name | grep -v $title_reg | awk '{print $3}')
  fi
  end

}

function main() {
  parse_params "$@"
  validate_params
  clean_image
}

main "$@"
