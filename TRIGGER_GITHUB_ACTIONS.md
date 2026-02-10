# 如何触发 r1.8.0_ms2.7.2_cann8.5.0_py3.11 的 GitHub Actions 构建

本文档说明如何使用 GitHub Actions 开始构建 `r1.8.0_ms2.7.2_cann8.5.0_py3.11` 版本。

## 方法一：使用 GitHub 网页界面（最简单）✨

这是最直接的方法，无需任何命令行工具。

### 步骤：

1. **访问 Actions 页面**
   ```
   https://github.com/JavaZeroo/mindformers-dockerfile/actions/workflows/build.yml
   ```

2. **点击 "Run workflow" 按钮**
   - 在页面右上角找到绿色的 "Run workflow" 按钮
   - 点击它

3. **填写参数**
   - **Branch**: 选择 `copilot/debug-dockerfile-error` 或 `master`
   - **Specify a tag to build**: 输入 `r1.8.0_ms2.7.2_cann8.5.0_py3.11`
   - **Push to Docker Hub**: ✓ (勾选，如果需要推送)
   - **Sync image to Huawei SWR**: ✓ (勾选，如果需要同步)

4. **开始构建**
   - 点击绿色的 "Run workflow" 按钮
   - 等待工作流开始

5. **监控进度**
   - 工作流会出现在列表中
   - 点击工作流查看详细日志
   - 预计构建时间：30-45 分钟

### 截图示例：

```
Actions 页面 → "Build and Push Docker Images" → "Run workflow"
     ↓
  填写参数:
  - Use workflow from: copilot/debug-dockerfile-error
  - tag: r1.8.0_ms2.7.2_cann8.5.0_py3.11
  - publish: ✓
  - sync_swr: ✓
     ↓
  点击 "Run workflow"
     ↓
  查看运行状态
```

---

## 方法二：使用命令行（GitHub CLI）🖥️

如果您已经安装并认证了 GitHub CLI，可以使用命令行触发。

### 前提条件：

```bash
# 1. 安装 GitHub CLI
# Ubuntu/Debian:
sudo apt install gh

# MacOS:
brew install gh

# Windows:
# 从 https://cli.github.com/ 下载安装

# 2. 认证
gh auth login
```

### 使用内置脚本：

```bash
# 进入仓库目录
cd /path/to/mindformers-dockerfile

# 运行触发脚本
./trigger_build.sh r1.8.0_ms2.7.2_cann8.5.0_py3.11
```

### 或使用 gh 命令：

```bash
# 触发工作流
gh workflow run build.yml \
  -f tag="r1.8.0_ms2.7.2_cann8.5.0_py3.11" \
  -f publish=true \
  -f sync_swr=true

# 查看运行状态
gh run list --workflow=build.yml --limit 5

# 查看详细日志
gh run view --log
```

---

## 方法三：使用 API（自动化）🤖

如果需要在脚本或 CI/CD 中自动触发，可以使用 GitHub API。

### 使用 curl：

```bash
# 需要 GitHub Personal Access Token
TOKEN="your_github_token"

curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN" \
  https://api.github.com/repos/JavaZeroo/mindformers-dockerfile/actions/workflows/build.yml/dispatches \
  -d '{
    "ref": "copilot/debug-dockerfile-error",
    "inputs": {
      "tag": "r1.8.0_ms2.7.2_cann8.5.0_py3.11",
      "publish": "true",
      "sync_swr": "true"
    }
  }'
```

### 获取 Personal Access Token：

1. 访问: https://github.com/settings/tokens
2. 点击 "Generate new token" → "Generate new token (classic)"
3. 选择权限: `workflow` (必需)
4. 生成并保存 token

---

## 验证构建状态

### 在网页上查看：

1. 访问: https://github.com/JavaZeroo/mindformers-dockerfile/actions
2. 找到最新的 "Build and Push Docker Images" 运行
3. 点击查看详细日志

### 使用命令行查看：

```bash
# 列出最近的运行
gh run list --workflow=build.yml

# 查看特定运行的状态
gh run view <run-id>

# 实时查看日志
gh run watch <run-id>
```

---

## 构建完成后

### 如果启用了 publish (推送到 Docker Hub)：

```bash
# 拉取镜像
docker pull <username>/mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11

# 运行
docker run --rm -it <username>/mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 bash
```

### 如果启用了 sync_swr (同步到华为 SWR)：

```bash
# 拉取镜像
docker pull swr.cn-central-221.ovaijisuan.com/<org>/mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11

# 运行
docker run --rm -it swr.cn-central-221.ovaijisuan.com/<org>/mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 bash
```

### 如果没有推送，下载 artifact：

1. 在工作流运行页面找到 "Artifacts" 部分
2. 下载 `mindformers-r1.8.0_ms2.7.2_cann8.5.0_py3.11` artifact
3. 解压并加载镜像：
   ```bash
   tar -xf mindformers-r1.8.0_ms2.7.2_cann8.5.0_py3.11.tar
   docker load -i mindformers-r1.8.0_ms2.7.2_cann8.5.0_py3.11.tar
   ```

---

## 常见问题

### Q: 工作流没有出现在列表中？

**A**: 等待几秒钟刷新页面，或检查您选择的分支是否正确。

### Q: 构建失败了怎么办？

**A**: 
1. 查看构建日志找出错误原因
2. 常见问题：
   - 磁盘空间不足（已通过 free-disk-space 解决）
   - 网络连接问题（重新运行工作流）
   - 配置错误（检查 versions.json）

### Q: 如何取消正在运行的构建？

**A**: 
- 网页：在工作流运行页面点击 "Cancel workflow"
- 命令行：`gh run cancel <run-id>`

### Q: 构建需要多长时间？

**A**: 通常需要 30-45 分钟，具体取决于网络速度和服务器负载。

---

## 工作流特性

### 自动磁盘空间清理
工作流会自动：
- 在构建前释放约 14GB 磁盘空间
- 删除 Android SDK、.NET 等不必要的工具
- 构建后清理 Docker 镜像缓存

### 构建配置
- **Dockerfile**: Dockerfile.cann8.5 (CANN 8.5.0 专用)
- **Python**: 3.11.4
- **CANN**: 8.5.0
- **MindSpore**: 2.7.2
- **MindFormers**: r1.8.0
- **运行器**: ubuntu-24.04-arm (ARM64)

### 磁盘空间监控
工作流在关键点记录磁盘使用情况：
- 清理后
- 构建后
- 保存镜像前后

---

## 推荐方法

| 方法 | 难度 | 速度 | 推荐场景 |
|------|------|------|----------|
| 网页界面 | ⭐ | ⭐⭐⭐ | 一次性构建 |
| trigger_build.sh | ⭐⭐ | ⭐⭐⭐⭐ | 频繁构建 |
| GitHub CLI | ⭐⭐ | ⭐⭐⭐⭐ | 命令行用户 |
| API | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 自动化集成 |

**对于大多数用户，推荐使用网页界面方法。**

---

## 相关文档

- **本地构建**: [BUILD_r1.8.0_GUIDE.md](./BUILD_r1.8.0_GUIDE.md)
- **快速开始**: [QUICKSTART.md](./QUICKSTART.md)
- **实战示例**: [PRACTICAL_EXAMPLE.md](./PRACTICAL_EXAMPLE.md)

---

**准备好开始构建了吗？访问 [Actions 页面](https://github.com/JavaZeroo/mindformers-dockerfile/actions/workflows/build.yml) 立即开始！** 🚀
