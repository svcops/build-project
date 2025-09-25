#!/bin/bash
# shellcheck disable=SC2164 disable=SC2086 disable=SC1090
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)

source <(curl -sSL $ROOT_URI/func/log.sh)
source <(curl -sSL $ROOT_URI/func/command_exists.sh)

# https://code.kubectl.net/devops/nvm/tags
nvm_version="v0.40.1"

log_info "install" "start install nvm by root user"

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
    if [ -d "$HOME/nvm" ]; then
      rm -rf $HOME/nvm
    fi

    if [ -d "$HOME/.nvm" ]; then
      rm -rf $HOME/.nvm
    fi

    if [ -f "$HOME/.npmrc" ]; then
      rm -rf "$HOME/.npmrc"
    fi
  }
  before_clear

  function unzip_and_move() {
    log_info "unzip_and_move" "..."
    tar -zxvf $download_target_file -C $HOME
    log_info "move" "mv $HOME/nvm $HOME/.nvm"
    mv $HOME/nvm $HOME/.nvm
  }

  unzip_and_move

  function do_config() {
    function config_bashrc() {
      log_info "config" "config $HOME/.bashrc"
      local config_bashrc_file="$HOME/.bashrc"

      log_warn "bashrc" "try delete"
      sed -i '/^# NVM CONFIG START$/,/^# NVM CONFIG END$/d' $config_bashrc_file

      local nvm_nodejs_mirror="https://npmmirror.com/mirrors/node/"
      cat <<EOF >>$config_bashrc_file
# NVM CONFIG START
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "\$NVM_DIR/bash_completion" ] && \. "\$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export NVM_NODEJS_ORG_MIRROR=$nvm_nodejs_mirror
# NVM CONFIG END
EOF
    }

    function config_npmrc() {
      log_info "config" "config $HOME/.npmrc"
      local config_npmrc_file="$HOME/.npmrc"
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
