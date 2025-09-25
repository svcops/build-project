#!/bin/bash
# shellcheck disable=SC1090,SC2181
set -euo pipefail
IFS=$'\n\t'

# 初始化根URI和依赖
[ -z "${ROOT_URI:-}" ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
export ROOT_URI=$ROOT_URI
source <(curl -sSL "$ROOT_URI/func/log.sh")

declare -g repo=""
declare -g target_name=""
declare -g proxy=""
declare -g specified_version=""
declare -g version=""

function show_usage() {
  cat <<EOF
GitHub Tag Download Script

Usage:
  ./dl_archive.sh -r <repo> [-o <output>] [-x <proxy>] [-v <version>] [-h]

Options:
  -r  GitHub repository (必填)，如 "openresty/lua-nginx-module"
  -o  输出文件前缀 (可选)，默认为仓库名最后一段
  -x  代理 (可选)，支持 http:// https:// socks5:// socks5h://
  -v  指定版本号 (可选)，默认使用最新 tag
  -h  显示帮助信息

Examples:
  ./dl_archive.sh -r openresty/lua-nginx-module
  ./dl_archive.sh -r openresty/lua-resty-core -v v0.1.20
  ./dl_archive.sh -r openresty/lua-nginx-module -o lua-nginx -x http://127.0.0.1:7890
EOF
}

function parse_arguments() {
  while getopts ":r:o:x:v:h" opt; do
    case ${opt} in
      r) repo="$OPTARG" ;;
      o) target_name="$OPTARG" ;;
      x) proxy="$OPTARG" ;;
      v) specified_version="$OPTARG" ;;
      h)
        show_usage
        exit 0
        ;;
      \?)
        log_error "opts" "Invalid option: -$OPTARG"
        show_usage
        exit 1
        ;;
      :)
        log_error "opts" "Option -$OPTARG requires an argument"
        show_usage
        exit 1
        ;;
    esac
  done
}

function fetch_latest_tag() {
  local url="https://api.github.com/repos/$repo/tags"
  local curl_opts=(-sSL)
  [ -n "$proxy" ] && curl_opts+=(-x "$proxy")

  local latest
  latest=$(curl "${curl_opts[@]}" "$url" | jq -r '.[0].name // empty')

  if [ -z "$latest" ]; then
    log_error "fetch tag" "Failed to get latest tag from $url"
    exit 1
  fi
  echo "$latest"
}

function validate_params() {
  if [ -z "$repo" ]; then
    log_error "validate" "Repository name is required"
    show_usage
    exit 1
  fi

  if [ -z "$target_name" ]; then
    target_name=$(basename "$repo")
    log_warn "validate" "Target name not specified, using default: $target_name"
  fi

  if [ -n "$proxy" ]; then
    if [[ ! "$proxy" =~ ^(http://|https://|socks5://|socks5h://) ]]; then
      log_error "validate" "Invalid proxy format: $proxy"
      exit 1
    fi
  fi

  if [ -z "$specified_version" ]; then
    version=$(fetch_latest_tag)
  else
    version="$specified_version"
  fi

  log_info "validate" "repo=$repo, target_name=$target_name, proxy=$proxy, version=$version"
}

function download_archive() {
  local download_url="https://github.com/$repo/archive/refs/tags/$version.tar.gz"
  local output_file="${target_name}-${version}.tar.gz"

  log_info "download" "url=$download_url"
  log_info "download" "output=$output_file"

  rm -f "$output_file"

  local curl_opts=(-SL -o "$output_file")
  [ -n "$proxy" ] && curl_opts+=(-x "$proxy")

  curl "${curl_opts[@]}" "$download_url"

  log_info "download" "Download completed: $output_file"
}

function main() {
  parse_arguments "$@"
  validate_params
  download_archive
}

main "$@"
