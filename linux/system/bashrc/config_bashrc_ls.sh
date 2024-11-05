#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086 disable=SC2154 disable=SC2028
if [ -z $ROOT_URI ]; then
  source <(curl -SL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
else
  echo -e "\033[0;32mROOT_URI=$ROOT_URI\033[0m"
fi
# ROOT_URI=https://dev.kubectl.net

source <(curl -SL $ROOT_URI/func/log.sh)
source <(curl -SL $ROOT_URI/func/detect_os.sh)

log_info "bashrc" "config bashrc ls"

file="$HOME/.bashrc"

if [ -f $file ]; then
  log_warn "bashrc" "try delete"
  sed -i '/^# BASHRC CONFIG LS START$/,/# BASHRC CONFIG LS END$/d' $file
fi

function init_apt_bashrc() {
  log "bashrc" "append bashrc"
  cat <<EOF >>$file
# BASHRC CONFIG LS START

# You may uncomment the following lines if you want \`ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "\$(dircolors)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "\$(dircolors -b ~/.dircolors)" || eval "\$(dircolors -b)"
  alias ls='ls --color=auto'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

alias lla='ls -ahlF --group-directories-first -X'
alias ll='ls -hlF --group-directories-first -X'
alias la='ls -A --group-directories-first -X'
alias l='ls -CF --group-directories-first -X'
#
# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

export PS1="\$PS1\[\e]1337;CurrentDir="'\$(pwd)\a\]'

# BASHRC CONFIG LS END

EOF
  cat $file
}

function other_todo() {
  log_warn "bashrc" "TODO ..."
}

if [ "$os_base_name" == "Ubuntu" ] || [ "$os_base_name" == "Debian" ]; then
  init_apt_bashrc
else
  other_todo
fi
