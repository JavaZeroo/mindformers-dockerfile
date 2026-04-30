# 构建 r1.8.0_ms2.7.2_cann8.5.0_py3.11 - 完整说明

本文档提供构建 `r1.8.0_ms2.7.2_cann8.5.0_py3.11` 版本的所有方法和详细说明。

## 📋 版本信息

| 组件 | 版本 |
|------|------|
| MindFormers | r1.8.0 |
| MindSpore | 2.7.2 |
| CANN | 8.5.0 |
| Python | 3.11.4 |
| Dockerfile | Dockerfile.cann8.5 |
| 架构 | ARM64 (aarch64) |

## 🚀 三种构建方法

### 方法 1: 自动构建脚本（最简单）✨

```bash
# 一条命令完成所有配置和构建
./build_image.sh r1.8.0_ms2.7.2_cann8.5.0_py3.11
```

**优点**:
- ✅ 自动从 versions.json 读取配置
- ✅ 自动验证文件和参数
- ✅ 彩色输出，易于理解
- ✅ 显示详细的构建信息
- ✅ 构建完成后显示运行命令

**适用场景**: 本地开发、快速测试、生产构建

---

### 方法 2: GitHub Actions（自动化）🤖

#### 使用 GitHub CLI:
```bash
./trigger_build.sh r1.8.0_ms2.7.2_cann8.5.0_py3.11
```

#### 手动触发:
1. 访问: https://github.com/JavaZeroo/mindformers-dockerfile/actions
2. 选择 "Build and Push Docker Images" 工作流
3. 点击 "Run workflow" 按钮
4. 在输入框中填写:
   - Tag: `r1.8.0_ms2.7.2_cann8.5.0_py3.11`
   - Publish to Docker Hub: ✓ (根据需要)
   - Sync to Huawei SWR: ✓ (根据需要)
5. 点击绿色 "Run workflow" 按钮

**优点**:
- ✅ 无需本地资源
- ✅ 自动清理磁盘空间（~14GB）
- ✅ 可直接推送到 Docker Hub 和华为 SWR
- ✅ 有完整的构建日志
- ✅ 可以下载构建好的镜像

**适用场景**: 远程构建、团队协作、镜像发布

---

### 方法 3: 手动构建（完全控制）⚙️

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

**优点**:
- ✅ 完全控制所有参数
- ✅ 可以自定义构建选项
- ✅ 适合调试和开发

**适用场景**: 调试问题、自定义构建、学习 Docker

---

## 📦 构建后使用

### 运行镜像
```bash
docker run --rm -it mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 bash
```

### 验证安装
```bash
# 进入容器后运行
python --version  # 应该显示 Python 3.11.4
python -c "import mindspore; print(mindspore.__version__)"  # 2.7.2
python -c "import mindformers; print(mindformers.__version__)"  # 1.8.0+
```

### 保存镜像
```bash
# 保存为 tar 文件
docker save mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 -o mindformers-r1.8.0.tar

# 在其他机器上加载
docker load -i mindformers-r1.8.0.tar
```

### 推送到仓库
```bash
# Docker Hub
docker tag mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 username/mindformers:r1.8.0
docker push username/mindformers:r1.8.0

# Huawei SWR
docker tag mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 swr.region.myhuaweicloud.com/org/mindformers:r1.8.0
docker push swr.region.myhuaweicloud.com/org/mindformers:r1.8.0
```

---

## ⚙️ 系统要求

### 硬件要求
- **架构**: ARM64 (aarch64) - **必需**
- **CPU**: 4+ 核心（推荐 8+）
- **内存**: 8GB+（推荐 16GB+）
- **磁盘**: 30GB+ 可用空间

### 软件要求
- Docker 20.10+
- jq（用于构建脚本）
- 稳定的网络连接

### 网络要求
构建过程需要访问：
- 华为云 OBS (CANN, MindSpore)
- GitCode (MindFormers 源码)
- 阿里云 PyPI 镜像

---

## ⏱️ 预计时间

| 方法 | 预计时间 | 说明 |
|------|----------|------|
| 本地构建 | 30-60分钟 | 取决于网络和硬件 |
| GitHub Actions | 30-45分钟 | 固定硬件配置 |
| 首次构建 | +10-15分钟 | 需要下载基础镜像 |

---

## 🔧 常见问题

### Q1: 磁盘空间不足
```bash
# 清理 Docker 缓存
docker system prune -a

# 检查磁盘空间
df -h
```

### Q2: 网络连接失败
```bash
# 使用代理
docker build --build-arg http_proxy=http://proxy:port ...

# 或使用 host 网络
docker build --network host ...
```

### Q3: 架构不匹配
```bash
# 检查当前架构
uname -m  # 必须是 aarch64

# 如果是 x86_64，需要在 ARM 机器上构建
```

### Q4: CANN 安装失败
- 确认下载 URL 正确
- 检查是否是 ARM64 版本
- 查看 `/tmp` 目录权限

### Q5: GitHub Actions 构建失败
- 检查磁盘空间清理是否生效
- 查看完整日志
- 确认所有 secrets 已配置

---

## 📚 相关文档

- **快速开始**: [QUICKSTART.md](./QUICKSTART.md)
- **完整指南**: [BUILD_r1.8.0_GUIDE.md](./BUILD_r1.8.0_GUIDE.md)
- **主 README**: [README.md](./README.md)

---

## 📞 获取帮助

遇到问题时：

1. **查看日志**: 构建日志通常包含错误详情
2. **检查文档**: 查看相关文档的故障排除部分
3. **搜索 Issues**: 在 GitHub Issues 中搜索类似问题
4. **提交 Issue**: 提供完整的错误信息和构建环境

---

## ✨ 特殊说明

### CANN 8.5.0 的变化

此版本使用 `Dockerfile.cann8.5`，与之前版本的主要区别：

1. **Ops 包**: 使用 `Ascend-cann-910b-ops` 而不是 `Ascend-cann-kernels`
2. **环境变量**: 更新了 CANN 8.5.0 的路径结构
3. **源码仓库**: 从 GitCode 克隆 MindFormers（不是 Gitee）
4. **依赖包**: 增加了更多运行时依赖

### 构建优化建议

- 使用 `--network host` 加速下载
- 首次构建后，Docker 会缓存中间层
- 可以使用 `docker build --no-cache` 强制重新构建
- 建议在网络良好时进行构建

---

## 🎯 总结

| 方法 | 难度 | 速度 | 推荐指数 |
|------|------|------|----------|
| build_image.sh | ⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| GitHub Actions | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 手动命令 | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

**推荐**: 优先使用 `build_image.sh` 进行本地构建，使用 GitHub Actions 进行镜像发布。

---

**祝您构建成功！** 🎉
