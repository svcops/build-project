# build project

## source log

```shell
source <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)

log "hello" "world"
```

## build gradle project

> build gradle project by docker

```shell
bash <(curl https://code.kubectl.net/devops/build-project/raw/branch/main/gradle/build.sh) \
  -c <cache_volume> \
  -i <gradle_image> \
  -x <gradle_command>
```

- `-c`: gradle缓存: 使用`docker volume`挂载
- `-i`: gradle的镜像
- `-x`: gradle的命令
  - e.g. : `gradle clean build -x test`

## build golang project

> build golang project by docker

```shell
bash <(curl https://code.kubectl.net/devops/build-project/raw/branch/main/golang/build.sh) \
  -c <cache_volume> \
  -i <gradle_image> \
  -x <gradle_command>
```

- `-c`: golang缓存: 使用`docker volume`挂载
- `-i`: golang的镜像
- `-x`: golang的命令
  - e.g. : `go build -v -o application`

## build docker's image (and push)

> by Dockerfile

```shell
bash <(curl https://code.kubectl.net/devops/build-project/raw/branch/main/gradle/build.sh) \
  -i <image_name> \
  -v <image_tag> \
  -r <re_tag_false> \
  -t <new_tag> \
  -p <push_flag>
```

- `-i`: 构建的镜像名称
- `-v`: 构建的镜像版本
- `-r`: 对于存在的镜像是否重新tag `true | false`
- `-t`: 对于存在的镜像，重新tag的版本
- `-p`: 是否push到仓库中

## docker image rm -f

参考 [for.sh](test/for.sh)

- `-i`: 镜像的名称
- `-s`: 删除的策略：默认策略 `contain_latest`
  - `contain_latest` 保留 `latest` 镜像，删除其他镜像
  - `remove_none` 删除 `none` 的镜像
  - `all`: 删除所有镜像

## docker install

debian系 安装 docker

```shell
bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/install_apt.sh) OS SRC
```