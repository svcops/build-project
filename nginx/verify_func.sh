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
  elif [ ! -f "$compose_file" ]; then
    log "nginx" "compose file does not exits, [compose_file=$compose_file,service_name=$service_name] then return 1"
    return 1
  fi

  local COMPOSE_FILE_FOLDER
  COMPOSE_FILE_FOLDER=$(cd "$(dirname "$compose_file")" && pwd)
  log "nginx" "compose file dir is $COMPOSE_FILE_FOLDER"
  local COMPOSE_FILE_NAME
  COMPOSE_FILE_NAME=$(basename "$compose_file")

  if [ -z "$service_name" ]; then
    log "nginx" "service_name is empty,[compose_file=$compose_file,service_name=$service_name] then return 1"
    return 1
  fi

  local output
  if command_exists docker-compose; then
    log "nginx" "use docker-compose"
    log "nginx" "$(docker-compose -f "$compose_file" run --rm -it "$service_name" nginx -v 2>&1 | tail -n 1)"
    log "nginx" "docker-compose -f $compose_file run --rm -it $service_name nginx -t 2>&1 | tail -n 2 | grep 'nginx:'"
    # 2>&1 重定向到标准输出
    output=$(docker-compose -f "$compose_file" run --rm -it "$service_name" nginx -t 2>&1 | tail -n 2 | grep 'nginx:')
  elif [ -S "/var/run/docker.sock" ]; then
    log "nginx" "use docker compose plugin (docker in docker)"

    log "nginx" "$(
      docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock \
        -v "$COMPOSE_FILE_FOLDER:$COMPOSE_FILE_FOLDER" \
        --privileged \
        docker \
        docker compose -f "$COMPOSE_FILE_FOLDER/$COMPOSE_FILE_NAME" run --rm -it "$service_name" nginx -v 2>&1 | tail -n 1
    )"
    local compose_command="docker compose -f $COMPOSE_FILE_FOLDER/$COMPOSE_FILE_NAME run --rm -it $service_name nginx -t 2>&1 | tail -n 2 | grep 'nginx:'"
    log "nginx" "\n  docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v $COMPOSE_FILE_FOLDER:$COMPOSE_FILE_FOLDER --privileged docker $compose_command"

    output=$(
      docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock \
        -v "$COMPOSE_FILE_FOLDER:$COMPOSE_FILE_FOLDER" \
        --privileged \
        docker \
        docker compose -f "$COMPOSE_FILE_FOLDER/$COMPOSE_FILE_NAME" run --rm -it "$service_name" nginx -t 2>&1 | tail -n 2 | grep 'nginx:'
    )

  else
    log "nginx" "use docker compose plugin"
    log "nginx" "$(docker compose -f "$compose_file" run --rm -it "$service_name" nginx -v 2>&1 | tail -n 1)"
    log "nginx" "docker compose -f $compose_file run --rm -it $service_name nginx -t 2>&1 | tail -n 2 | grep 'nginx:'"
    output=$(docker compose -f "$compose_file" run --rm -it "$service_name" nginx -t 2>&1 | tail -n 2 | grep 'nginx:')
  fi

  if [ -z "$output" ]; then
    log "nginx" "output is empty. Unknown Configuration, [compose_file=$compose_file,service_name=$service_name] then return 1"
    return 1
  else
    log "nginx" ">>> output <<<\n\n$output\n"
    log "nginx" ">>> output <<<"
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
    log "nginx" "Unknown Configuration, [compose_file=$compose_file,service_name=$service_name] then return 1"
    return 1
  fi

}
