# Quick Start: Build r1.8.0_ms2.7.2_cann8.5.0_py3.11

## 最快速的构建方式

### 选项 1: 使用自动脚本（推荐）

```bash
# 单条命令完成构建
./build_image.sh r1.8.0_ms2.7.2_cann8.5.0_py3.11
```

### 选项 2: 使用 GitHub Actions（在线构建）

1. 访问: https://github.com/JavaZeroo/mindformers-dockerfile/actions
2. 选择 "Build and Push Docker Images" 工作流
3. 点击 "Run workflow"
4. 输入标签: `r1.8.0_ms2.7.2_cann8.5.0_py3.11`
5. 点击绿色的 "Run workflow" 按钮

### 选项 3: 手动命令（完全控制）

```bash
docker build --network host -f Dockerfile.cann8.5 \
  --build-arg PYTHON_VERSION=3.11.4 \
  --build-arg CANN_TOOLKIT_URL="https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.5.0/Ascend-cann-toolkit_8.5.0_linux-aarch64.run" \
  --build-arg CANN_KERNELS_URL="https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.5.0/Ascend-cann-910b-ops_8.5.0_linux-aarch64.run" \
  --build-arg MS_WHL_URL="https://ms-release.obs.cn-north-4.myhuaweicloud.com/2.7.2/MindSpore/unified/aarch64/mindspore-2.7.2-cp311-cp311-linux_aarch64.whl" \
  --build-arg MINDFORMERS_GIT_REF=r1.8.0 \
  -t mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 .
```

## 运行构建好的镜像

```bash
docker run --rm -it mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 bash
```

## 预计构建时间

- **本地构建**: 30-60 分钟（取决于网络和硬件）
- **GitHub Actions**: 30-45 分钟

## 磁盘空间需求

- **最小**: 20GB 可用空间
- **推荐**: 30GB+ 可用空间

## 预先检查

```bash
# 检查 Docker
docker --version

# 检查磁盘空间
df -h /

# 检查架构（必须是 aarch64）
uname -m

# 检查 jq（如果使用脚本）
jq --version
```

## 遇到问题？

查看完整文档: [BUILD_r1.8.0_GUIDE.md](./BUILD_r1.8.0_GUIDE.md)
