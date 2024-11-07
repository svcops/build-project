#!/bin/bash
# shellcheck disable=SC1090 disable=SC2086 disable=SC2028
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
echo -e "\033[0;32mROOT_URI=$ROOT_URI\033[0m"

source <(curl -sSL $ROOT_URI/func/log.sh)
source <(curl -sSL $ROOT_URI/func/command_exists.sh)

date_general=$(date '+%Y-%m-%d %H:%M:%S')
datetime_version=$(date '+%Y-%m-%d_%H-%M-%S')
datetime_tight_version=$(date '+%Y%m%d%H%M%S')
date_version=$(date '+%Y-%m-%d')
date_tight_version=$(date '+%Y%m%d')

log_info "date" "date_general=$date_general"
log_info "date" "datetime_version=$datetime_version"
log_info "date" "date_tight_version=$datetime_tight_version"
log_info "date" "date_version=$date_version"
log_info "date" "date_tight_version=$date_tight_version"

if command_exists git; then
  if git log --oneline >/dev/null 2>&1; then
    log_info "git" "git log --abbrev-commit --pretty=oneline -n 1"
    git_version=$(git log --abbrev-commit --pretty=oneline -n 1 | head -c 7)
    log_info "git" "git_version=$git_version"
  else
    log_warn "git" "No commit record"
  fi
fi
