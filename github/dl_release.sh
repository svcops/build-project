#!/bin/bash
# shellcheck disable=SC1090 disable=SC2181
set -euo pipefail
# 初始化根URI和依赖
[ -z "${ROOT_URI:-}" ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
export ROOT_URI=$ROOT_URI
source <(curl -sSL "$ROOT_URI/func/log.sh")
