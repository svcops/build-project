#!/bin/bash

registry="docker.io"
image_name_list=("hello" "world")

# 使用 for 循环来遍历数组中的每个元素
for image_name in "${image_name_list[@]}"; do
  echo "remove image is : $registry/$image_name"
  bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/rmi.sh) \
    -i "$registry/$image_name" \
    -s "contain_latest"
done
