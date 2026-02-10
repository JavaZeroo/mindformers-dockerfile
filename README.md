# MindFormers Dockerfile

## 仓库用途
该仓库提供用于构建 MindFormers 训练环境的 Dockerfile 和版本配置，
可以在 Ascend 平台上快速搭建包含指定 MindSpore、CANN 及 Python 版本的镜像。

## 快速开始

### 方式一：使用自动构建脚本（推荐）

```bash
# 查看可用版本
./build_image.sh

# 构建指定版本
./build_image.sh r1.8.0_ms2.7.2_cann8.5.0_py3.11
```

### 方式二：使用 GitHub Actions（云端构建）⭐

**网页触发（最简单）**:
- 访问 [Actions 页面](https://github.com/JavaZeroo/mindformers-dockerfile/actions/workflows/build.yml)
- 点击 "Run workflow"，填写参数
- 查看 [网页触发详细指南](./WEB_TRIGGER_GUIDE.md)

**命令行触发**:
```bash
# 使用快速触发脚本
./start_build.sh

# 或使用 GitHub CLI 触发构建
./trigger_build.sh r1.8.0_ms2.7.2_cann8.5.0_py3.11
```

详细说明请参考：
- **网页触发指南**: [WEB_TRIGGER_GUIDE.md](./WEB_TRIGGER_GUIDE.md) ⭐ 推荐
- **快速开始**: [QUICKSTART.md](./QUICKSTART.md)
- **触发 GitHub Actions**: [TRIGGER_GITHUB_ACTIONS.md](./TRIGGER_GITHUB_ACTIONS.md)
- **完整指南**: [BUILD_r1.8.0_GUIDE.md](./BUILD_r1.8.0_GUIDE.md)

## 前置条件
- 已安装 Docker（推荐版本 `Docker version 26.1.4, build 5650f9b`）
- 可访问华为云/Ascend 软件源以下载 CANN、MindSpore 等依赖
- 已安装 `curl`、`jq` 等工具
- 至少 30GB 可用磁盘空间

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

构建镜像时将配置项作为 `--build-arg` 传入：

```bash
git clone https://gitee.com/jimmyisme/mindformers-dockerfile.git
cd mindformers-dockerfile
docker build --network host -t mindformers:${VERSION} \
  $(jq -r ".\"${VERSION}\" | to_entries | .[] | \"--build-arg \\(.key)=\\(.value)\"" versions.json) \
  -f Dockerfile.base .
```

## 运行示例

```bash
docker run --rm -it mindformers:${VERSION} bash
```

