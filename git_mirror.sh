#!/bin/bash
# shellcheck disable=SC2164
SHELL_FOLDER=$(
  cd "$(dirname "$0")"
  pwd
)
cd "$SHELL_FOLDER"

git remote set-url origin https://gitlab.com/iprt/build-project.git
git remote -vv
git push -u origin HEAD

echo "reset"
git remote set-url origin https://code.kubectl.net/devops/build-project

git remote -vv
