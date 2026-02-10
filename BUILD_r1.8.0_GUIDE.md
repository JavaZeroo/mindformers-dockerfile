# 构建 r1.8.0_ms2.7.2_cann8.5.0_py3.11 镜像指南

本文档说明如何构建 `r1.8.0_ms2.7.2_cann8.5.0_py3.11` 版本的 MindFormers Docker 镜像。

## 版本信息

- **标签**: r1.8.0_ms2.7.2_cann8.5.0_py3.11
- **MindFormers**: r1.8.0
- **MindSpore**: 2.7.2
- **CANN**: 8.5.0
- **Python**: 3.11.4
- **Dockerfile**: Dockerfile.cann8.5

## 构建方式

### 方式一：使用提供的构建脚本（推荐）

1. **确保已安装 jq 工具**:
```bash
# Ubuntu/Debian
sudo apt-get install jq

# MacOS
brew install jq
```

2. **运行构建脚本**:
```bash
./build_image.sh r1.8.0_ms2.7.2_cann8.5.0_py3.11
```

脚本会自动：
- 从 `versions.json` 读取配置
- 验证所有必需的文件存在
- 使用正确的参数构建 Docker 镜像
- 显示构建状态和结果

### 方式二：手动构建

如果你想手动构建，可以使用以下命令：

```bash
docker build \
  --network host \
  -f Dockerfile.cann8.5 \
  --build-arg PYTHON_VERSION=3.11.4 \
  --build-arg CANN_TOOLKIT_URL="https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.5.0/Ascend-cann-toolkit_8.5.0_linux-aarch64.run" \
  --build-arg CANN_KERNELS_URL="https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.5.0/Ascend-cann-910b-ops_8.5.0_linux-aarch64.run" \
  --build-arg MS_WHL_URL="https://ms-release.obs.cn-north-4.myhuaweicloud.com/2.7.2/MindSpore/unified/aarch64/mindspore-2.7.2-cp311-cp311-linux_aarch64.whl" \
  --build-arg MINDFORMERS_GIT_REF=r1.8.0 \
  -t mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 \
  .
```

### 方式三：使用 GitHub Actions（自动化）

可以通过 GitHub Actions 触发自动构建：

1. **访问 GitHub Actions 页面**:
   - 进入仓库的 Actions 标签页
   - 选择 "Build and Push Docker Images" 工作流

2. **手动触发工作流**:
   - 点击 "Run workflow"
   - 在 "Specify a tag to build" 字段中输入: `r1.8.0_ms2.7.2_cann8.5.0_py3.11`
   - 选择是否推送到 Docker Hub 和 Huawei SWR
   - 点击 "Run workflow" 按钮

3. **监控构建进度**:
   - 工作流会自动清理磁盘空间（释放约 14GB）
   - 构建过程约需 30-60 分钟
   - 可以查看日志了解详细进度

## 构建后操作

### 运行镜像

```bash
docker run --rm -it mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 bash
```

### 保存镜像为 tar 文件

```bash
docker save mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 -o mindformers-r1.8.0_ms2.7.2_cann8.5.0_py3.11.tar
```

### 推送到镜像仓库

```bash
# Docker Hub
docker tag mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 your-username/mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11
docker push your-username/mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11

# Huawei SWR
docker tag mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 swr.cn-central-221.ovaijisuan.com/your-org/mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11
docker push swr.cn-central-221.ovaijisuan.com/your-org/mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11
```

## 前置要求

### 系统要求

- **架构**: ARM64 (aarch64)
- **操作系统**: Linux (推荐 Ubuntu 22.04 或 24.04)
- **Docker**: 版本 >= 20.10
- **磁盘空间**: 至少 30GB 可用空间
- **内存**: 建议至少 8GB

### 网络要求

构建过程需要访问以下资源：
- 华为云 OBS (下载 CANN 和 MindSpore)
- GitCode/Gitee (克隆 MindFormers 仓库)
- 阿里云镜像 (pip 包)

如果网络受限，建议配置代理或使用 `--network host` 选项。

## 常见问题

### 1. 磁盘空间不足

**错误**: `no space left on device`

**解决方案**:
- 清理 Docker 缓存: `docker system prune -a`
- 删除未使用的镜像: `docker image prune -a`
- 释放系统空间: 删除不必要的文件

### 2. 网络连接失败

**错误**: `wget: unable to resolve host address`

**解决方案**:
- 检查网络连接
- 配置 DNS: `echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf`
- 使用代理: `docker build --build-arg http_proxy=... --build-arg https_proxy=...`

### 3. CANN 安装失败

**错误**: CANN toolkit installation failed

**解决方案**:
- 确认使用的是 ARM64 架构
- 检查 CANN 安装包 URL 是否正确
- 查看 Dockerfile 中的安装日志

### 4. MindFormers 构建失败

**错误**: build.sh execution failed

**解决方案**:
- 检查 MindFormers git ref 是否存在
- 确认 MindSpore 版本与 MindFormers 兼容
- 查看构建日志中的详细错误信息

## CANN 8.5.0 特殊说明

此版本使用 `Dockerfile.cann8.5`，它与之前版本的主要区别：

1. **环境变量更新**: 使用 CANN 8.5.0 的新路径结构
2. **依赖包更新**: 包含更多运行时依赖
3. **Ops 包**: 使用 `Ascend-cann-910b-ops` 替代旧的 kernels 包
4. **Git 源**: 从 GitCode 克隆 MindFormers（而不是 Gitee）

## 验证构建

构建完成后，可以运行以下命令验证：

```bash
# 进入容器
docker run --rm -it mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 bash

# 检查 Python 版本
python --version  # 应该显示 Python 3.11.4

# 检查 MindSpore
python -c "import mindspore; print(mindspore.__version__)"  # 应该显示 2.7.2

# 检查 MindFormers
python -c "import mindformers; print(mindformers.__version__)"  # 应该显示 1.8.0 或 1.9.0

# 检查 CANN
ls -la /usr/local/Ascend/  # 应该看到 cann-8.5.0 目录
```

## 额外资源

- **MindFormers 官方文档**: https://gitee.com/mindspore/mindformers
- **MindSpore 下载**: https://www.mindspore.cn/install
- **Ascend CANN**: https://www.hiascend.com/software/cann

## 技术支持

如遇到问题，请：
1. 查看构建日志
2. 检查 GitHub Issues
3. 参考官方文档
4. 在社区提问
