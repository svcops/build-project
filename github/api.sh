#!/bin/bash
function fetch_latest_tag() {
  local repo=$1
  local proxy=$2
  local url="https://api.github.com/repos/$repo/tags"
  local curl_opts=(-sSL)
  [ -n "$proxy" ] && curl_opts+=(-x "$proxy")
  local latest
  latest=$(curl "${curl_opts[@]}" "$url" | jq -r '.[0].name // empty')
  if [ -z "$latest" ]; then
    echo ""
  fi
  echo "$latest"
}
