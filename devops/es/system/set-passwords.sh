#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086 disable=SC2155 disable=SC2128 disable=SC2028 disable=SC2086 disable=SC2162 disable=SC2117
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh) && export ROOT_URI=$ROOT_URI
# ROOT_URI=https://dev.kubectl.net

source <(curl -sSL $ROOT_URI/func/log.sh)

read -p "input es user: (default is es) :" es_user
# shellcheck disable=SC2086
if [ -z $es_user ]; then
  es_user="es"
fi

if ! id $es_user &>/dev/null; then
  log_error "elasticsearch" "user $es_user is not exist"
  exit 1
fi

log_info "elasticsearch" "es_user=$es_user"

if [ ! -f "bin/elasticsearch-setup-passwords" ]; then
  log_error "elasticsearch" "bin/elasticsearch-setup-passwords is not exist"
  exit 1
else
  log_info "elasticsearch" "bin/elasticsearch-setup-passwords is exist"

  log_info "elasticsearch" "Switching to user $es_user"
  read -p "input es password: " es_password

  if [ -z $es_password ]; then
    log_error "elasticsearch" "es_password is empty"
    exit 1
  fi

#  sudo -u $es_user bash -c '
##!/bin/bash
#es_password="$1"
#if [ -z "$es_password" ]; then
#  echo "es_password is empty"
#  exit 1
#fi
## Set passwords for built-in users
#echo -e "y\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n" |
#  bin/elasticsearch-setup-passwords interactive
#' bash "$es_password"

# 高版本多了一个确定密码的步骤
  sudo -u $es_user bash -c '
#!/bin/bash
es_password="$1"
if [ -z "$es_password" ]; then
  echo "es_password is empty"
  exit 1
fi
# Set passwords for built-in users
echo -e "y\ny\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n$es_password\n" |
  bin/elasticsearch-setup-passwords interactive
' bash "$es_password"
fi
