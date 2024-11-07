#!/bin/bash
# shellcheck disable=SC1090 disable=SC2028 disable=SC2086
[ -z $ROOT_URI ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
echo -e "\033[0;32mROOT_URI=$ROOT_URI\033[0m"
source <(curl -sSL $ROOT_URI/func/log.sh)

date_general=$(date '+%Y-%m-%d %H:%M:%S')
datetime_version=$(date '+%Y-%m-%d_%H-%M-%S')
datetime_tight_version=$(date '+%Y%m%d%H%M%S')
date_version=$(date '+%Y-%m-%d')
date_tight_version=$(date '+%Y%m%d')

log_info "print data version" "data_general:           $date_general"
log_info "print data version" "datetime_version:       $datetime_version"
log_info "print data version" "datetime_tight_version: $datetime_tight_version"
log_info "print data version" "date_version:           $date_version"
log_info "print data version" "date_tight_version:     $date_tight_version"
