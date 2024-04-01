#!/bin/bash
# shellcheck disable=SC1090 disable=SC2164
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/command_exists.sh)

log "nginx" "Verify the nginx configuration file that docker-compose starts"
compose_file=$2
service_name=$1

if [ -z "$compose_file" ]; then
  log "nginx" "compose file is empty, try use docker-compose.yml or docker-compose.yaml"
  if [ -f "docker-compose.yml" ]; then
    compose_file="docker-compose.yml"
  elif [ -f "docker-compose.yaml" ]; then
    compose_file="docker-compose.yaml"
  else
    log "nginx" "cannot find docker-compose.yml or docker-compose.yaml in current directory"
    exit 1
  fi
elif [ ! -f "$compose_file" ]; then
  log "nginx" "compose file does not exits, [compose_file=$compose_file,service_name=$service_name] then exit 1"
  exit 1
fi

COMPOSE_FILE_FOLDER=$(cd "$(dirname "$compose_file")" && pwd)
log "nginx" "compose file dir is $COMPOSE_FILE_FOLDER"

if [ -z "$service_name" ]; then
  log "nginx" "service_name is empty,[compose_file=$compose_file,service_name=$service_name] then exit 1"
  exit 1
fi

if command_exists docker-compose; then
  log "nginx" "use docker-compose"
  log "nginx" "docker-compose -f $compose_file run --rm -it $service_name nginx -t | tail -n 2 | grep 'nginx:'"
  output=$(docker-compose -f "$compose_file" run --rm -it "$service_name" nginx -t | tail -n 2 | grep 'nginx:')
else
  log "nginx" "use docker compose plugin"
  log "nginx" "docker compose -f $compose_file run --rm -it $service_name nginx -t | tail -n 2 | grep 'nginx:'"
  output=$(docker compose -f "$compose_file" run --rm -it "$service_name" nginx -t | tail -n 2 | grep 'nginx:')
fi

if [ -z "$output" ]; then
  log "nginx" "output is empty. Unknown Configuration, [compose_file=$compose_file,service_name=$service_name] then exit 1"
  exit 1
fi

# template

#nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
#nginx: configuration file /etc/nginx/nginx.conf test is successful

#nginx: [emerg] unknown directive "xworker_processes" in /etc/nginx/nginx.conf:1
#nginx: configuration file /etc/nginx/nginx.conf test failed

reason=$(echo "$output" | sed -n '1p')
status=$(echo "$output" | sed -n '2p')

if echo "$status" | grep -q "successful"; then
  log "nginx" "$status"
elif echo "$status" | grep -q "failed"; then
  log "nginx" "$reason"
  exit 1
else
  log "nginx" "Unknown Configuration, [compose_file=$compose_file,service_name=$service_name] then exit 1"
  exit 1
fi
