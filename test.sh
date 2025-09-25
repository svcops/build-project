#!/bin/bash
# shellcheck disable=SC2086 disable=SC2155 disable=SC1090 disable=SC2028

# 严格模式：遇到错误立即退出，未定义变量报错
set -euo pipefail

# 初始化根URI和依赖
[ -z "${ROOT_URI:-}" ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)

echo "ROOT_URI: $ROOT_URI"
