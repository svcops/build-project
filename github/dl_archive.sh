#!/bin/bash
# shellcheck disable=SC1090 disable=SC2181
set -euo pipefail
# 初始化根URI和依赖
[ -z "${ROOT_URI:-}" ] && source <(curl -sSL https://gitlab.com/iprt/shell-basic/-/raw/main/build-project/basic.sh)
export ROOT_URI=$ROOT_URI
source <(curl -sSL "$ROOT_URI/func/log.sh")

declare -g repo=""
declare -g target_name=""
declare -g proxy=""
declare -g specified_version=""

function show_usage() {
  # 完善下面的帮助信息
  cat <<EOF
GitHub Tag Download Script Usage:
  -r  GitHub repository name (required), e.g.: "openresty/lua-nginx-module"
  -o  Target file name (optional, default: repo name's basename) with version tag, e.g.: "lua-nginx-module-v0.10.28.tar.gz"
  -x  Proxy server (optional, default: no proxy)
  -v  Specific version tag to download (optional, default: latest tag)
  -h  Show this help message
Examples:
  ./dl_archive.sh -r openresty/lua-nginx-module -o lua-nginx-module -x http://
  ./dl_archive.sh -r openresty/lua-resty-core -v v0.1.20
EOF

}

function parse_arguments() {
  while getopts ":r:o:x:v:h" opt; do
    case ${opt} in
      r)
        log_info "get opts" "repo name: $OPTARG"
        repo="$OPTARG"
        ;;
      o)
        log_info "get opts" "target name: $OPTARG"
        target_name="$OPTARG"
        ;;
      x)
        log_info "get opts" "proxy: $OPTARG"
        proxy="$OPTARG"
        ;;
      v)
        log_info "get opts" "specified version: $OPTARG"
        specified_version="$OPTARG"
        ;;
      h)
        show_usage
        exit 0
        ;;
      \?)
        log_error "get opts" "Invalid option: -$OPTARG"
        show_usage
        exit 1
        ;;
      :)
        log_error "get opts" "Option -$OPTARG requires an argument"
        show_usage
        exit 1
        ;;
    esac
  done
}

declare -g version=""

function validate_params() {
  if [ -z "$repo" ]; then
    log_error "validate params" "Repository name is required"
    show_usage
    exit 1
  fi

  if [ -z "$target_name" ]; then
    target_name=$(basename "$repo")
    log_warn "validate params" "Target name not specified, using default: $target_name"
  fi

  if [ -z "$proxy" ]; then
    proxy=""
  else
    # 确保代理格式正确 http:// https:// sock5h://
    if [[ ! "$proxy" =~ ^(http://|https://|socks5h://) ]]; then
      log_error "validate params" "Invalid proxy format: $proxy"
      show_usage
      exit 1
    fi
  fi

  if [ -z "$specified_version" ]; then
    if [ -z "$proxy" ]; then
      version=$(curl -sSL "https://api.github.com/repos/$repo/tags" | jq -r '.[0].name')
    else
      version=$(curl -sSL -x "$proxy" "https://api.github.com/repos/$repo/tags" | jq -r '.[0].name')
    fi
  else
    version="$specified_version"
  fi

  if [ -z "$version" ]; then
    log_error "validate params" "Failed to retrieve version from GitHub API"
    exit 1
  fi

  log_info "validate params" "repo=$repo, target_name=$target_name, proxy=$proxy, version=$version"

}

function download_archive() {
  local download_url="https://github.com/$repo/archive/refs/tags/$version.tar.gz"

  log_info "download" "repo=$repo, target_name=$target_name, version=$version, download_url=$download_url, proxy=$proxy"

  local output_file="$target_name-$version.tar.gz"

  if [ -n "$output_file" ]; then
    if rm -rf "$output_file" 2>/dev/null; then
      log_info "download" "Removed existing file: $output_file"
    else
      log_warn "download" "No existing file to remove: $output_file"
    fi
  fi

  if [ -z "$proxy" ]; then
    log_info "download" "curl -SL \"$download_url\" -o \"$output_file\""
    curl -SL "$download_url" -o "$output_file"
  else
    log_info "download" "curl -SL -x \"$proxy\" \"$download_url\" -o \"$output_file\""
    curl -SL -x "$proxy" "$download_url" -o "$output_file"
  fi

  if [ $? -ne 0 ]; then
    log_error "download" "Failed to download $download_url"
    exit 1
  fi
}

function main() {
  parse_arguments "$@"
  validate_params
  download_archive
}

main "$@"
