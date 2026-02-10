# 实战示例：构建和使用 r1.8.0_ms2.7.2_cann8.5.0_py3.11

这是一个完整的实战示例，展示从零开始到成功运行 MindFormers 的全过程。

## 📝 前期准备

### 1. 环境检查
```bash
# 检查架构（必须是 aarch64）
uname -m
# 输出: aarch64 ✓

# 检查 Docker
docker --version
# 输出: Docker version 20.10.x 或更高 ✓

# 检查磁盘空间（至少需要 30GB）
df -h /
# 确保 Available 列显示 30G+ ✓

# 检查 jq（用于构建脚本）
jq --version
# 如果没有，安装: sudo apt-get install jq
```

### 2. 克隆仓库
```bash
# 克隆仓库
git clone https://github.com/JavaZeroo/mindformers-dockerfile.git
cd mindformers-dockerfile

# 查看可用版本
cat versions.json | jq -r 'keys[]'
```

## 🚀 方法一：使用自动脚本（推荐）

### 步骤 1: 运行构建脚本
```bash
# 赋予执行权限（如果需要）
chmod +x build_image.sh

# 开始构建
./build_image.sh r1.8.0_ms2.7.2_cann8.5.0_py3.11
```

### 步骤 2: 等待构建完成
构建过程会显示：
```
Building MindFormers Docker image for version: r1.8.0_ms2.7.2_cann8.5.0_py3.11

Configuration:
  Dockerfile: Dockerfile.cann8.5
  Python Version: 3.11.4
  CANN Toolkit: https://...
  ...

Starting Docker build...
```

大约 30-60 分钟后，看到：
```
✓ Build completed successfully!

To run the image:
  docker run --rm -it mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 bash
```

### 步骤 3: 验证镜像
```bash
# 查看构建的镜像
docker images | grep mindformers

# 输出示例:
# mindformers  r1.8.0_ms2.7.2_cann8.5.0_py3.11  abc123  2 minutes ago  8.5GB
```

## 🔍 方法二：使用 GitHub Actions

### 步骤 1: Fork 仓库（如果需要）
如果您想在自己的账户下构建，先 Fork 仓库。

### 步骤 2: 触发工作流

#### 使用脚本触发:
```bash
# 确保已安装和认证 GitHub CLI
gh auth login

# 触发构建
./trigger_build.sh r1.8.0_ms2.7.2_cann8.5.0_py3.11

# 查看运行状态
gh run list --workflow=build.yml
```

#### 手动触发:
1. 访问: https://github.com/JavaZeroo/mindformers-dockerfile/actions
2. 点击 "Build and Push Docker Images"
3. 点击 "Run workflow"
4. 输入 `r1.8.0_ms2.7.2_cann8.5.0_py3.11`
5. 点击运行

### 步骤 3: 监控构建
```bash
# 查看最新运行
gh run list --workflow=build.yml --limit 5

# 查看详细日志
gh run view --log
```

### 步骤 4: 下载镜像（如果需要）
如果 publish 设置为 true，镜像会被推送到 Docker Hub，您可以直接拉取：
```bash
docker pull username/mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11
```

## 🧪 运行和测试

### 启动容器
```bash
# 启动交互式容器
docker run --rm -it mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 bash
```

### 基础验证
在容器内运行：
```bash
# 1. 检查 Python 版本
python --version
# 预期输出: Python 3.11.4

# 2. 检查 MindSpore
python -c "import mindspore; print(f'MindSpore: {mindspore.__version__}')"
# 预期输出: MindSpore: 2.7.2

# 3. 检查 MindFormers
python -c "import mindformers; print(f'MindFormers: {mindformers.__version__}')"
# 预期输出: MindFormers: 1.8.0 或更高

# 4. 检查 CANN
ls -la /usr/local/Ascend/
# 应该看到 cann-8.5.0 目录

# 5. 检查环境变量
echo $ASCEND_TOOLKIT_HOME
# 预期输出: /usr/local/Ascend/cann-8.5.0
```

### 运行示例代码
```python
# 在容器内创建测试脚本
cat > test_mindformers.py << 'EOF'
import mindspore as ms
import mindformers as mf

print("="*50)
print(f"MindSpore version: {ms.__version__}")
print(f"MindFormers version: {mf.__version__}")
print("="*50)

# 简单测试
from mindformers import AutoModel, AutoTokenizer

print("\n✓ All imports successful!")
print("✓ Environment is ready for MindFormers!")
EOF

# 运行测试
python test_mindformers.py
```

## 💾 保存和分发

### 保存镜像为文件
```bash
# 退出容器
exit

# 保存镜像
docker save mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 \
  -o mindformers-r1.8.0.tar

# 查看文件大小
ls -lh mindformers-r1.8.0.tar

# 压缩（可选）
gzip mindformers-r1.8.0.tar
```

### 在其他机器上使用
```bash
# 复制 tar 文件到目标机器，然后：

# 如果压缩了，先解压
gunzip mindformers-r1.8.0.tar.gz

# 加载镜像
docker load -i mindformers-r1.8.0.tar

# 验证
docker images | grep mindformers

# 运行
docker run --rm -it mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 bash
```

### 推送到镜像仓库
```bash
# 登录 Docker Hub
docker login

# 打标签
docker tag mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 \
  yourusername/mindformers:r1.8.0

# 推送
docker push yourusername/mindformers:r1.8.0

# 其他人拉取
docker pull yourusername/mindformers:r1.8.0
```

## 🐛 问题排查实例

### 问题 1: 磁盘空间不足
```bash
# 症状
Error: write /var/lib/docker/...: no space left on device

# 解决
docker system prune -a -f
df -h /  # 检查释放的空间

# 如果还不够，删除旧镜像
docker images
docker rmi <image_id>
```

### 问题 2: 网络超时
```bash
# 症状
ERROR: failed to download ...
Timeout was reached

# 解决方案 1: 重试构建
./build_image.sh r1.8.0_ms2.7.2_cann8.5.0_py3.11

# 解决方案 2: 使用代理
export HTTP_PROXY=http://proxy:port
export HTTPS_PROXY=http://proxy:port
./build_image.sh r1.8.0_ms2.7.2_cann8.5.0_py3.11

# 解决方案 3: 在网络更好的时间重试
```

### 问题 3: CANN 安装失败
```bash
# 症状
CANN toolkit installation failed

# 检查
# 1. 确认架构
uname -m  # 必须是 aarch64

# 2. 查看详细日志
docker build ... 2>&1 | tee build.log
grep -i error build.log

# 3. 确认 URL 正确
curl -I "CANN_TOOLKIT_URL"  # 应该返回 200
```

## 📊 性能基准

在标准配置下的实测数据：

| 阶段 | 时间 | 说明 |
|------|------|------|
| 下载基础镜像 | 2-5分钟 | 首次需要 |
| 安装 Python | 10-15分钟 | 从源码编译 |
| 下载 CANN | 5-10分钟 | 约 2GB |
| 安装 CANN | 5-8分钟 | |
| 安装 MindSpore | 2-3分钟 | |
| 构建 MindFormers | 10-15分钟 | |
| **总计** | **35-60分钟** | 首次构建 |
| 后续构建 | 20-30分钟 | 有缓存 |

## ✅ 成功标志

构建成功后，您应该能够：

1. ✓ 启动容器无错误
2. ✓ 导入 mindspore 和 mindformers
3. ✓ 运行简单的模型推理
4. ✓ 访问 CANN 工具链
5. ✓ 查看正确的版本号

## 📚 下一步

构建成功后，您可以：

1. **运行示例**: 查看 MindFormers 官方示例
2. **训练模型**: 开始您的训练任务
3. **部署应用**: 将镜像用于生产环境
4. **自定义**: 基于此镜像创建自定义版本

## 🎓 学习资源

- MindFormers 文档: https://gitee.com/mindspore/mindformers
- MindSpore 教程: https://www.mindspore.cn/tutorials
- CANN 开发指南: https://www.hiascend.com/document

---

**恭喜！您已成功构建和使用 MindFormers Docker 镜像！** 🎉

如有问题，请参考 [BUILD_r1.8.0_GUIDE.md](./BUILD_r1.8.0_GUIDE.md) 或提交 Issue。
