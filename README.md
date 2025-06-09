# Docker 版本

`Docker version 26.1.4, build 5650f9b`

# 构建镜像

```bash
git clone https://gitee.com/jimmyisme/mindformers-dockerfile.git
cd mindformers-dockerfile
docker build --network host -t mindformers-r1.5.0-mindspore-2.6.0.rc1-py3.11:20250609 --build-arg TARGETPLATFORM=linux/arm64 -f Dockerfile.r1.5.0 .
```