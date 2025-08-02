# Docker 版本

`Docker version 26.1.4, build 5650f9b`

# 构建镜像

```bash
git clone https://gitee.com/jimmyisme/mindformers-dockerfile.git
cd mindformers-dockerfile
docker build --network host -t mindformers-r1.5.0-mindspore-2.6.0.rc1-py3.11:20250609 --build-arg TARGETPLATFORM=linux/arm64 -f Dockerfile.r1.5.0 .
```

## GitHub Actions

仓库提供了一个手动触发的工作流，用于根据 `versions.json` 构建并推送镜像。
在 GitHub 页面中执行 **Run workflow** 并填写 `tags` 输入，输入值为 `versions.json` 中对应的镜像标签，多个标签使用逗号分隔，例如：

```
r1.6.0_ms2.7.0-rc1_cann8.2.RC1_py3.11
```

工作流只会构建在 `tags` 中指定的镜像，并使用 QEMU 与 Buildx 生成 `linux/arm64` 架构的镜像。
