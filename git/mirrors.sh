#!/bin/bash
# shellcheck disable=SC2086

function is_same_repo() {
  local repo_url=$1

  local curr_origin=$2
  [[ -z "$curr_origin" ]] && {
    echo "get current origin from git command"
    curr_origin=$(git remote get-url origin)
    # 去掉  curr_origin 后面的 .git
    curr_origin=${curr_origin%.git}
  }

  if [[ -z "$curr_origin" ]]; then
    echo "cannot get current origin"
    exit 1
  fi

  [[ "$repo_url" == "$curr_origin" ]] && {
    return 0
  }
  return 1
}

function mirror_to_code() {
  local repo=$1
  local branch=$2
  local code_repo="https://code.kubectl.net/$1"
  is_same_repo "$code_repo" && {
    echo "same repo, skip mirror to : $code_repo"
    return
  }

  [[ -z "$branch" ]] && {
    echo "get current branch from git command"
    branch=$(git rev-parse --abbrev-ref HEAD)
  }

  [[ -z "$branch" ]] && {
    echo "cannot get current branch"
    return 1
  }

  echo "mirror to code repo: $code_repo, branch: $branch"
  git push --mirror $code_repo
}

function mirror_to_gitlab() {
  local repo=$1
  local branch=$2
  local gitlab_repo="git@gitlab.com:$repo"
  is_same_repo "$gitlab_repo" && {
    echo "same repo, skip mirror to : $gitlab_repo"
    return
  }

  [[ -z "$branch" ]] && {
    echo "get current branch from git command"
    branch=$(git rev-parse --abbrev-ref HEAD)
  }

  [[ -z "$branch" ]] && {
    echo "cannot get current branch"
    return 1
  }
  echo "mirror to gitlab repo: $gitlab_repo, branch: $branch"
  git push $gitlab_repo $branch
}

function mirror_to_github() {
  local repo=$1
  local branch=$2

  local github_repo="git@github.com:$repo"
  is_same_repo "$github_repo" && {
    echo "same repo, skip mirror to : $github_repo"
    return
  }

  [[ -z "$branch" ]] && {
    echo "get current branch from git command"
    branch=$(git rev-parse --abbrev-ref HEAD)
  }

  [[ -z "$branch" ]] && {
    echo "cannot get current branch"
    return 1
  }
  echo "mirror to github repo: $github_repo, branch: $branch"
  git push --mirror $github_repo
}
