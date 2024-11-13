#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086 disable=SC2155 disable=SC2128 disable=SC2028
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
echo -e "\033[0;32mROOT_URI=$ROOT_URI\033[0m"
source <(curl -SL $ROOT_URI/func/log.sh)
source <(curl -SL $ROOT_URI/func/command_exists.sh)

container_name=$1
es_password=$2

if [ -z $container_name ]; then
  container_name="elasticsearch"
  log_info "elasticsearch" "default container_name=$container_name"
fi

if [ -z $es_password ]; then
  es_password="elastic"
  log_info "elasticsearch" "default es_password=$es_password"
fi

if ! command_exists docker; then
  log_error "elasticsearch" "docker is not installed"
  exit 1
fi

if [ "$(docker ps -a --filter "name=$container_name" --format "{{.Names}}")" == "$container_name" ]; then
  log_info "elasticsearch" "Container $container_name exists."
else
  log_error "elasticsearch" "Container $container_name does not exist."
  exit 1
fi

# Set passwords for built-in users
# ERROR: Invalid username [elastic]... Username [elastic] is reserved and may not be used., with exit code 65
# ERROR: Invalid username [kibana]... Username [kibana] is reserved and may not be used., with exit code 65
# ERROR: Invalid username [apm_system]... Username [apm_system] is reserved and may not be used., with exit code 65

usernames=("admin" "kibana2" "logstash" "beats" "apm_system2")
for username in "${usernames[@]}"; do
  log_warn "elasticsearch" "delete user $username"
  docker exec -it $container_name \
    bin/elasticsearch-users userdel $username
done

log_info "elasticsearch" "set passwords for admin user role superuser"
docker exec -it $container_name \
  bin/elasticsearch-users useradd admin -p $es_password -r superuser

log_info "elasticsearch" "set passwords for kibana2 user role kibana_system"
docker exec -it $container_name \
  bin/elasticsearch-users useradd kibana2 -p $es_password -r kibana_system

log_info "elasticsearch" "set passwords for logstash user role logstash_system"
docker exec -it $container_name \
  bin/elasticsearch-users useradd logstash -p $es_password -r logstash_system

log_info "elasticsearch" "set passwords for beats user role beats_system"
docker exec -it $container_name \
  bin/elasticsearch-users useradd beats -p $es_password -r beats_system

log_info "elasticsearch" "set passwords for apm_system user role apm_system"
docker exec -it $container_name \
  bin/elasticsearch-users useradd apm_system -p $es_password -r apm_system
