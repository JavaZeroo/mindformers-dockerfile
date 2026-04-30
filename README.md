# MindFormers Dockerfile

## 仓库用途
该仓库提供用于构建 MindFormers 训练环境的 Dockerfile 和版本配置，
可以在 Ascend 平台上快速搭建包含指定 MindSpore、CANN 及 Python 版本的镜像。

## 前置条件
- 已安装 Docker（推荐版本 `Docker version 26.1.4, build 5650f9b`）
- 可访问华为云/Ascend 软件源以下载 CANN、MindSpore 等依赖
- 已安装 `curl`、`jq` 等工具

## 参数说明
- `PYTHON_VERSION`：镜像中安装的 Python 版本
- `CANN_TOOLKIT_URL`：CANN Toolkit 安装包下载地址
- `CANN_KERNELS_URL`：CANN Kernels 安装包下载地址
- `MS_WHL_URL`：MindSpore 轮子包下载地址
- `MINDFORMERS_GIT_REF`：MindFormers 仓库的 Git 分支或标签

## 选择版本并构建
`versions.json` 列出了可用的版本及其参数，示例：

```bash
# 下载版本配置
curl -LO https://raw.githubusercontent.com/jimmyisme/mindformers-dockerfile/main/versions.json

# 查看可用版本
jq -r 'keys[]' versions.json

# 选择需要的版本
VERSION=r1.6.0_ms2.7.0-rc1_cann8.2.RC1_py3.11
```

构建镜像时将配置项作为 `--build-arg` 传入，并使用版本配置文件中指定的 Dockerfile：

```bash
git clone https://gitee.com/jimmyisme/mindformers-dockerfile.git
cd mindformers-dockerfile
docker build --network host -t mindformers:${VERSION} \
  $(jq -r ".\"${VERSION}\" | to_entries | .[] | \"--build-arg \\(.key)=\\(.value)\"" versions.json) \
  -f $(jq -r ".\"${VERSION}\".DOCKERFILE" versions.json) .
```

## 运行示例

```bash
docker run --rm -it mindformers:${VERSION} bash
```

> 当前项目主力 Dockerfile 为 `Dockerfile`，当版本配置中指定 CANN 8.5 及以上时会自动使用该文件。旧版 CANN 8.2/8.3 等仍可继续使用 `Dockerfile.base`。
