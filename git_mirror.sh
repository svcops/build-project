#!/bin/bash
git remote set-url origin https://gitlab.com/iprt/build-project
git remote -vv
git push -u origin HEAD

echo "reset"
git remote set-url origin https://code.kubectl.net/devops/build-project

git remote -vv
