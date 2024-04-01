#!/bin/bash
# shellcheck disable=SC1090 disable=SC2164
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/command_exists.sh)

function verify_nginx_configuration() {
  log "nginx" "Verify the nginx configuration file that docker-compose starts"
  local compose_file=$2
  local service_name=$1

  if [ -z "$compose_file" ]; then
    log "nginx" "compose file is empty, try use docker-compose.yml or docker-compose.yaml"
    if [ -f "docker-compose.yml" ]; then
      compose_file="docker-compose.yml"
    elif [ -f "docker-compose.yaml" ]; then
      compose_file="docker-compose.yaml"
    else
      log "nginx" "cannot find docker-compose.yml or docker-compose.yaml in current directory"
      return 1
    fi
  fi

  local COMPOSE_FILE_FOLDER
  COMPOSE_FILE_FOLDER=$(cd "$(dirname "$compose_file")" && pwd)
  cd "$COMPOSE_FILE_FOLDER"
  log "nginx" "current dir is $(pwd)"

  if [ -z "$service_name" ]; then
    log "nginx" "service_name is empty, then return"
    return 1
  fi

  local output
  if command_exists docker-compose; then
    log "nginx" "use docker-compose"
    output=$(docker-compose -f "$compose_file" run --rm -it "$service_name" nginx -t | tail -n 2 | grep 'nginx:')
  else
    log "nginx" "use docker compose plugin"
    output=$(docker compose -f "$compose_file" run --rm -it "$service_name" nginx -t | tail -n 2 | grep 'nginx:')
  fi

  if [ -z "$output" ]; then
    log "nginx" "output is empty. Unknown Configuration"
    return 1
  fi

  # template

  #nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
  #nginx: configuration file /etc/nginx/nginx.conf test is successful

  #nginx: [emerg] unknown directive "xworker_processes" in /etc/nginx/nginx.conf:1
  #nginx: configuration file /etc/nginx/nginx.conf test failed

  local reason
  reason=$(echo "$output" | sed -n '1p')
  local status
  status=$(echo "$output" | sed -n '2p')

  if echo "$status" | grep -q "successful"; then
    log "nginx" "$status"
    return 0
  elif echo "$status" | grep -q "failed"; then
    log "nginx" "$reason"
    return 1
  else
    log "nginx" "Unknown Configuration"
    return 1
  fi

}
