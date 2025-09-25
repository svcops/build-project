#!/bin/bash
# shellcheck disable=SC2164
SHELL_FOLDER=$(cd "$(dirname "$0")" && pwd)
cd "$SHELL_FOLDER"

echo "mirror to gitlab"
git push git@gitlab.com:svcops/build-project main

echo "mirror to github"
git push --mirror git@github.com:svcops/build-project
