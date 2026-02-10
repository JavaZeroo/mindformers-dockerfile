# GitHub Actions 构建快速指南

## 🎯 目标
使用 GitHub Actions 构建 `r1.8.0_ms2.7.2_cann8.5.0_py3.11` 版本

---

## ⚡ 最快方法（3步）

### 第1步：访问 Actions 页面
```
https://github.com/JavaZeroo/mindformers-dockerfile/actions/workflows/build.yml
```

### 第2步：点击 "Run workflow"
在页面右上角找到绿色按钮

### 第3步：填写参数并启动
```
Branch: copilot/debug-dockerfile-error (或 master)
tag: r1.8.0_ms2.7.2_cann8.5.0_py3.11
Push to Docker Hub: ✓
Sync image to Huawei SWR: ✓
```

点击绿色的 "Run workflow" 按钮！

---

## 📱 界面操作流程

```
┌─────────────────────────────────────────────────────────┐
│  GitHub Actions 页面                                     │
│  https://github.com/JavaZeroo/.../actions/workflows/... │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  [Run workflow ▼] 按钮                                   │
│  点击展开表单                                            │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  Use workflow from: [copilot/debug-dockerfile-error ▼]  │
│  Specify a tag to build: [r1.8.0_ms2.7.2_cann8.5.0_py3.11]│
│  Push to Docker Hub: [✓]                                │
│  Sync image to Huawei SWR: [✓]                          │
│                                                          │
│  [Run workflow] 按钮                                     │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  ✓ 工作流已触发                                          │
│  预计时间: 30-45 分钟                                    │
│  点击查看实时日志                                        │
└─────────────────────────────────────────────────────────┘
```

---

## 🖥️ 命令行方法

### 使用快速脚本：
```bash
./start_build.sh
```

### 使用完整脚本：
```bash
./trigger_build.sh r1.8.0_ms2.7.2_cann8.5.0_py3.11
```

### 使用 gh 命令：
```bash
gh workflow run build.yml \
  -f tag="r1.8.0_ms2.7.2_cann8.5.0_py3.11" \
  -f publish=true \
  -f sync_swr=true
```

---

## 📊 构建监控

### 查看运行状态：
```bash
gh run list --workflow=build.yml --limit 5
```

### 查看实时日志：
```bash
gh run watch
```

### 网页查看：
```
https://github.com/JavaZeroo/mindformers-dockerfile/actions
```

---

## ⏱️ 时间线

```
0 min    ━━ 工作流启动
2 min    ━━ 清理磁盘空间 (~14GB)
5 min    ━━ 开始 Docker 构建
15 min   ━━ 安装 Python
25 min   ━━ 安装 CANN
35 min   ━━ 安装 MindSpore & MindFormers
40 min   ━━ 保存镜像
45 min   ━━ 推送到镜像仓库 ✓
```

---

## ✅ 成功标志

构建成功后，您将看到：
- ✅ 所有步骤显示绿色 ✓
- ✅ 镜像已推送到 Docker Hub
- ✅ 镜像已同步到华为 SWR
- ✅ Artifact 可供下载

---

## 🎉 构建完成

### 拉取镜像：
```bash
# 从 Docker Hub
docker pull <username>/mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11

# 从华为 SWR
docker pull swr.cn-central-221.ovaijisuan.com/<org>/mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11
```

### 运行镜像：
```bash
docker run --rm -it mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11 bash
```

---

## 📚 相关文档

- 详细说明: [TRIGGER_GITHUB_ACTIONS.md](./TRIGGER_GITHUB_ACTIONS.md)
- 本地构建: [BUILD_r1.8.0_GUIDE.md](./BUILD_r1.8.0_GUIDE.md)
- 实战示例: [PRACTICAL_EXAMPLE.md](./PRACTICAL_EXAMPLE.md)

---

**现在就开始构建！** 🚀

