# build project

<!-- TOC -->

* [build project](#build-project)
    * [functions](#functions)
        * [log func](#log-func)
        * [command_exists func](#command_exists-func)
        * [detect ssh port](#detect-ssh-port)
    * [build gradle's project](#build-gradles-project)
    * [build maven's project](#build-mavens-project)
    * [build golang's project](#build-golangs-project)
    * [docker](#docker)
        * [build docker's image (and push)](#build-dockers-image-and-push)
        * [remove docker's image](#remove-dockers-image)
        * [install docker](#install-docker)
    * [linux](#linux)
        * [bashrc](#bashrc)
    * [develop](#develop)
        * [config maven](#config-maven)
        * [verify nginx configuration](#verify-nginx-configuration)

<!-- TOC -->

## functions

### log func

```shell
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/log.sh)

log "hello" "world"
```

### command_exists func

```shell
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/func/command_exists.sh)

if command_exists docker ; then
    echo "command docker exists"
fi
```

### detect ssh port

```shell
ssh_port="$(bash <(https://code.kubectl.net/devops/build-project/raw/branch/main/func/ssh_port.sh)"
echo "ssh port is $ssh_port"
```

## build gradle's project

build gradle's project by docker

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

## build maven's project

build maven's project by docker

```shell
bash <(curl https://code.kubectl.net/devops/build-project/raw/branch/main/gradle/build.sh) \
  -c <cache_volume> \
  -i <maven_image> \
  -s <path/to/settings.xml> \
  -x <maven_command>
```

- `-c`: maven缓存
- `-i`: maven镜像
- `-s`: maven `settings.xml` 在本地的路径
- `-x`: maven执行的命令
    - e.g. : `mvn clean install -Dmaven.test.skip=true`

## build golang's project

build golang's project by docker

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

## docker

### build docker's image (and push)

> by Dockerfile

```shell
bash <(curl https://code.kubectl.net/devops/build-project/raw/branch/main/gradle/build.sh) \
  -f [path\to\Dockerfile] \
  -i <image_name> \
  -v <image_tag> \
  -r <re_tag_false> \
  -t <new_tag> \
  -p <push_flag>
```

- `-f`: `Dockefile` 的路径, 默认的构建基础路径在Dockerfile的路径下
    - 可选的参数, 如果没有, 会寻找执行脚本路径下的 `DOCKERFILE` 或 `Dockerfile` 或 `dockerfile`
- `-i`: 构建的镜像名称
- `-v`: 构建的镜像版本
- `-r`: 对于存在的镜像是否重新tag `true | false`
- `-t`: 对于存在的镜像，重新tag的版本
- `-p`: 是否push到仓库中

### remove docker's image

参考 [for.sh](.example/for.sh)

- `-i`: 镜像的名称
- `-s`: 删除的策略：默认策略 `contain_latest`
    - `contain_latest` 保留 `latest` 镜像，删除其他镜像
    - `remove_none` 删除 `none` 的镜像
    - `all`: 删除所有镜像

### install docker

**debian系** 安装 docker

```shell
bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/docker/install/install_apt.sh) SRC
````

- SRC: 源 (`docker` 官方源 / `tsinghua` 清华源 / `aliyun` 阿里云)

## linux

### bashrc

debian

```shell
bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/linux/system/bashrc/init_debian.sh)
```

## develop

### config maven

config maven `settings.xml`

```shell
bash <(curl -SL https://code.kubectl.net/devops/build-project/raw/branch/main/maven/config.sh)
```

### verify nginx configuration

验证基于`docker-compose`启动的nginx的配置文件

```shell
source <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/nginx/verify_func.sh)
if verify_nginx_configuration nginx path/to/docker-compose.yml; then
  log "verify" "verify success, then start"
else
  log "verify" "verify failed, then edit again"
fi
```

- 方法参数一: service_name
- 方法参数二: compose文件位置，可传递，默认寻找执行脚本目录下的 `docker-compose.yml` 或者 `docker-comopose.yaml`

快速验证

```shell
bash <(curl -sSL https://code.kubectl.net/devops/build-project/raw/branch/main/nginx/verify.sh) nginx path\to\docker-compose.yml
```

- `nginx` 是 `docker-compose.yaml`中定义的`service`
- 第二个参数 `docker-comopse.yml`的路径，默认会在执行脚本的当前路径下寻找 `docker-compose.yml` 或者 `docker-compose.yaml` 