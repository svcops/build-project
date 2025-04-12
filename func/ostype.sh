#!/bin/bash

function is_windows() {
  # 判断是不是windows
  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    log_info "windows" "windows system"
    return 0
  else
    log_info "windows" "not windows system"
    return 1
  fi
}
