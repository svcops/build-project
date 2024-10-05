#!/bin/bash
# shellcheck disable=SC2164 disable=SC2086 disable=SC1090
source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
source <(curl -sSL $ROOT_URI/func/log.sh)
source <(curl -sSL $ROOT_URI/func/command_exists.sh)

# https://code.kubectl.net/devops/nvm/tags
nvm_version="v0.40.1"

log_info "install" "start install nvm"

function prepare() {
  if ! command_exists curl; then
    log_error "prepare" "command wget does not exist"
    exit 1
  fi
}

prepare

download_target_file="/tmp/nvm$nvm_version.tar.gz"

function download() {
  if [ -f "$download_target_file" ]; then
    rm -rf $download_target_file
  fi

  curl https://code.kubectl.net/devops/nvm/archive/$nvm_version.tar.gz -o $download_target_file

  if [ -f "$download_target_file" ]; then
    log_info "download" "download success"
  else
    log_error "download" "download failed"
    exit 1
  fi

}

function unzip_with_config() {

  function before_clear() {
    log_info "before_clear" "..."
    if [ -d "/root/nvm" ]; then
      rm -rf /root/nvm
    fi

    if [ -d "/root/.nvm" ]; then
      rm -rf /root/.nvm
    fi

    if [ -f "/root/.npmrc" ]; then
      rm -rf "/root/.npmrc"
    fi
  }
  before_clear

  function unzip_and_move() {
    log_info "unzip_and_move" "..."
    tar -zxvf $download_target_file -C /root
    log_info "move" "mv /root/nvm /root/.nvm"
    mv /root/nvm /root/.nvm
  }

  unzip_and_move

  function do_config() {
    function config_bashrc() {
      log_info "config" "config /root/.bashrc"
      local config_bashrc_file="/root/.bashrc"

      log_warn "bashrc" "try delete"
      sed -i '/^#bf563159-1c46-4e10-a67a-e64bc308e517/,/#c0eee075-f614-4ffd-87f4-41f62655512d/d' $config_bashrc_file

      cat <<EOF >>$config_bashrc_file
#bf563159-1c46-4e10-a67a-e64bc308e517
export NVM_DIR="$$HOME/.nvm"
[ -s "$$NVM_DIR/nvm.sh" ] && \. "$$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$$NVM_DIR/bash_completion" ] && \. "$$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export NVM_NODEJS_ORG_MIRROR=http://npm.taobao.org/mirrors/node
#c0eee075-f614-4ffd-87f4-41f62655512d
EOF
    }

    function config_npmrc() {
      log_info "config" "config /root/.npmrc"
      local config_npmrc_file="/root/.npmrc"
      cat >>$config_npmrc_file <<EOF
registry=https://registry.npmmirror.com
EOF
    }

    config_bashrc
    config_npmrc

  }

  do_config
}

function download_clear() {
  log_info "clear" "clear download file"
  rm -rf $download_target_file
}

download
unzip_with_config
download_clear
