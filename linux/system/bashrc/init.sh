#!/bin/bash
# shellcheck disable=SC1090 disable=SC2154
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/detect_os.sh)

log "bashrc" "init bashrc"

if [ -f "/root/.bashrc" ]; then
  log "bashrc" "try delete"
  sed -i '/^#9d5049f5-3f12-4004-9ac8-196956e91184/,/#58efd70b-e5be-4d58-856a-5807ed05b29d/d' /root/.bashrc
fi

function init_apt_bashrc() {
  log "bashrc" "append bashrc"
  cat <<EOF >>/root/.bashrc
#9d5049f5-3f12-4004-9ac8-196956e91184

# You may uncomment the following lines if you want \`ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "\$(dircolors)"
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

#58efd70b-e5be-4d58-856a-5807ed05b29d

EOF

  cat /root/.bashrc
}

function init_yum_bashrc() {
  log "bashrc" "TODO append bashrc"
}

if [ "$os_base_name" == "Ubuntu" ] || [ "$os_base_name" == "Debian" ]; then
  init_apt_bashrc
else
  init_yum_bashrc
fi
