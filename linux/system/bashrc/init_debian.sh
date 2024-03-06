#!/bin/bash
# shellcheck disable=SC1090
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)

log "bashrc" "init bashrc"

log "bashrc" "try delete"

sed '/^#9d5049f5-3f12-4004-9ac8-196956e91184/,/#58efd70b-e5be-4d58-856a-5807ed05b29d/d' /etc/sysctl.conf

log "bashrc" "then append"
cat <<EOF >>/root/.bashrc
#9d5049f5-3f12-4004-9ac8-196956e91184

# You may uncomment the following lines if you want \`ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "\$(dircolors)"
alias ls='ls \$LS_OPTIONS'
alias ll='ls \$LS_OPTIONS -lh'
alias ll='ls \$LS_OPTIONS -lh'
alias l='ls \$LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

export PS1="\$PS1\[\e]1337;CurrentDir="'\$(pwd)\a\]'

#58efd70b-e5be-4d58-856a-5807ed05b29d

EOF
