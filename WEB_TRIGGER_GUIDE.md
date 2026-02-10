# 使用网页触发 GitHub Actions - 完整图文指南

由于 token 验证在当前环境遇到限制，这里提供详细的网页操作指南。

## 🎯 目标

触发 `r1.8.0_ms2.7.2_cann8.5.0_py3.11` 版本的 Docker 镜像构建

## 📋 详细步骤

### 第 1 步：访问工作流页面

在浏览器中打开以下链接：

```
https://github.com/JavaZeroo/mindformers-dockerfile/actions/workflows/build.yml
```

您会看到 "Build and Push Docker Images" 工作流页面。

### 第 2 步：触发工作流

1. **找到 "Run workflow" 按钮**
   - 位置：页面右上角（工作流列表上方）
   - 外观：绿色按钮，带有 ▼ 下拉箭头
   - 点击此按钮

2. **填写表单**
   
   弹出的表单有以下字段：

   ```
   ┌─────────────────────────────────────────────┐
   │ Use workflow from                           │
   │ ┌─────────────────────────────────────────┐ │
   │ │ Branch: copilot/debug-dockerfile-error  │ │
   │ └─────────────────────────────────────────┘ │
   │                                             │
   │ Specify a tag to build                      │
   │ ┌─────────────────────────────────────────┐ │
   │ │ r1.8.0_ms2.7.2_cann8.5.0_py3.11        │ │
   │ └─────────────────────────────────────────┘ │
   │                                             │
   │ ☑ Push to Docker Hub                        │
   │ ☑ Sync image to Huawei SWR                  │
   │                                             │
   │ [   Run workflow   ]                        │
   └─────────────────────────────────────────────┘
   ```

   **填写说明：**
   - **Branch**: 选择 `copilot/debug-dockerfile-error`（如果当前不是这个分支）
   - **tag**: 输入 `r1.8.0_ms2.7.2_cann8.5.0_py3.11`
   - **Push to Docker Hub**: 保持勾选 ✓
   - **Sync image to Huawei SWR**: 保持勾选 ✓

3. **启动工作流**
   - 点击表单底部的绿色 "Run workflow" 按钮
   - 页面会自动刷新

### 第 3 步：查看运行状态

1. **找到您的运行**
   - 页面刷新后，最新的运行会出现在列表顶部
   - 状态显示为 🟡 黄色圆点（正在运行）

2. **进入运行详情**
   - 点击运行标题进入详情页
   - 显示格式：`Build and Push Docker Images #数字`

3. **查看作业进度**
   
   您会看到以下作业：
   
   ```
   Jobs
   ├─ prepare          [✓ 完成 1-2分钟]
   ├─ build            [🔄 运行中 35-40分钟]
   ├─ push             [⏳ 等待中]
   └─ sync             [⏳ 等待中]
   ```

### 第 4 步：监控构建日志

1. **查看实时日志**
   - 点击 `build` 作业
   - 展开每个步骤查看详细日志

2. **关键步骤和预计时间**
   
   ```
   Set up job                              [30秒]
   Run actions/checkout@v4                 [30秒]
   Free Disk Space                         [2-3分钟]
   Check disk space                        [5秒]
   Build image                             [30-40分钟]
     ├─ Stage 1: Install Python            [10分钟]
     ├─ Stage 2: Install CANN              [10分钟]
     └─ Stage 3: Final image               [15-20分钟]
   Upload image artifact                   [2-3分钟]
   ```

### 第 5 步：等待完成

**总时间**: 约 30-45 分钟

**时间线**:
```
00:00  🟢 开始 - prepare 作业启动
00:02  🟢 构建 - build 作业启动
00:05  📦 清理磁盘（释放 ~14GB）
00:10  🐍 安装 Python 3.11.4
00:20  🔧 安装 CANN 8.5.0
00:30  🧠 安装 MindSpore 2.7.2
00:35  🤖 构建 MindFormers r1.8.0
00:40  💾 保存 Docker 镜像
00:42  📤 上传 artifact
00:45  ✅ 构建完成
00:47  📮 推送到 Docker Hub
00:50  🔄 同步到华为 SWR
00:52  🎉 全部完成！
```

### 第 6 步：验证结果

**成功标志**:
- ✅ 所有作业显示绿色勾号
- ✅ `prepare` - Complete
- ✅ `build` - Complete  
- ✅ `push` - Complete
- ✅ `sync` - Complete

**查看产物**:
- 在运行详情页面底部找到 "Artifacts"
- 下载 `mindformers-r1.8.0_ms2.7.2_cann8.5.0_py3.11` (如果已上传)

**拉取镜像**:
```bash
# 从 Docker Hub
docker pull <your-username>/mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11

# 从华为 SWR
docker pull swr.cn-central-221.ovaijisuan.com/<org>/mindformers:r1.8.0_ms2.7.2_cann8.5.0_py3.11
```

## 🔧 故障排除

### 如果构建失败

1. **查看失败日志**
   - 点击失败的作业
   - 展开红色 ❌ 的步骤
   - 查看错误信息

2. **常见问题**
   
   | 问题 | 解决方案 |
   |------|----------|
   | 磁盘空间不足 | 已通过 free-disk-space 自动解决 |
   | 网络超时 | 重新运行工作流（点击 "Re-run jobs"） |
   | 下载失败 | 检查 URL 是否有效，重试 |

3. **重新运行**
   - 点击页面右上角的 "Re-run jobs"
   - 选择 "Re-run all jobs" 或 "Re-run failed jobs"

### 取消运行

如果需要取消：
- 点击页面右上角的 "Cancel workflow"
- 确认取消

## 📊 监控选项

### 选项 1：网页实时监控（推荐）

**优势**:
- ✅ 图形界面，清晰易懂
- ✅ 实时日志，自动滚动
- ✅ 可以展开/折叠步骤
- ✅ 彩色输出，错误突出显示
- ✅ 可以下载完整日志

### 选项 2：邮件通知

GitHub 会自动发送邮件通知：
- 🟢 工作流开始
- ✅ 工作流成功
- ❌ 工作流失败

### 选项 3：移动端 GitHub App

可以在手机上：
- 查看运行状态
- 阅读日志
- 接收推送通知

## 💡 提示

1. **页面自动刷新**: 现代浏览器会自动刷新显示最新状态

2. **多标签页**: 可以在新标签页中打开，继续做其他事情

3. **书签**: 将 Actions 页面加入书签以便快速访问

4. **日志搜索**: 在日志页面使用 Ctrl+F (或 Cmd+F) 搜索特定内容

5. **时间显示**: 每个步骤显示实际运行时间

## 🔗 快速链接

- **工作流页面**: https://github.com/JavaZeroo/mindformers-dockerfile/actions/workflows/build.yml
- **所有运行**: https://github.com/JavaZeroo/mindformers-dockerfile/actions
- **仓库主页**: https://github.com/JavaZeroo/mindformers-dockerfile

## 📚 相关文档

- `TRIGGER_GITHUB_ACTIONS.md` - 完整触发指南
- `GITHUB_ACTIONS_QUICKSTART.md` - 快速开始
- `TOKEN_TROUBLESHOOTING.md` - Token 故障排除
- `BUILD_r1.8.0_GUIDE.md` - 构建指南

---

**准备好了吗？** 现在就访问 [Actions 页面](https://github.com/JavaZeroo/mindformers-dockerfile/actions/workflows/build.yml) 开始构建！🚀
