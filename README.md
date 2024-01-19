# build project

## build gradle project

> build gradle project by docker

```shell
bash <(curl https://code.kubectl.net/devops/build-project/raw/branch/main/gradle/build.sh) \
-c <cache_volume> \
-i <gradle_image> \
-x <gradle_command>
```
- `-c`: cache volume
- `-i`: image_name
- `-x`: gradle's command
  - e.g. : `gradle clean build -x test`

## build docker's image (and push)

> by Dockerfile