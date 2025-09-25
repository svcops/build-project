#!/bin/bash

  tar zxvf "$output_file"

  # 自动推断解压后的目录名
  local unpacked_dir=$(tar -tzf "$output_file" | head -1 | cut -f1 -d"/")

  # 重命名目录
  if [ -n "$target_name" ]; then
    rm -rf "$target_name"
    mv "$unpacked_dir" "$target_name"
  fi