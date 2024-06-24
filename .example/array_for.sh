#!/bin/bash
# shellcheck disable=SC1090
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/basic.sh)

array=("A" "B" "C")
for element in "${array[@]}"; do
  echo "$element"
done

echo "----"

node_image="node:22"
array=('npm install --registry=https://registry.npmmirror.com' 'npm run build')
for element in "${array[@]}"; do
  # shellcheck disable=SC2154
  echo "bash <(curl -sSL $ROOT_URI/node/build.sh)" \
    -i "$node_image" \
    -x "$element"
done
