#!/bin/bash
# shellcheck disable=SC2164,SC2086,SC1090
SHELL_FOLDER=$(cd "$(dirname "$0")" && pwd) && cd "$SHELL_FOLDER"
ROOT_URI=https://dev.kubectl.net
source <(curl -sSL $ROOT_URI/git/mirrors.sh)

mirror_to_code "devops/build-project"
mirror_to_gitlab "svcops/build-project"
mirror_to_github "svcops/build-project"
