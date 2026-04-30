# GitHub Actions 工作流触发和监控指南

## 问题诊断

提供的 token 无效或已过期。可能的原因：
1. Token 已过期
2. Token 权限不足（需要 `workflow` 权限）
3. Token 已被撤销

## 解决方案

### 方法 1：创建新的 Personal Access Token

1. **访问 GitHub Token 设置**
   ```
   https://github.com/settings/tokens
   ```

2. **创建新 Token**
   - 点击 "Generate new token" → "Generate new token (classic)"
   - Note: 填写描述，如 "MindFormers Workflow Trigger"
   - Expiration: 选择过期时间（建议 90 天）
   - **必需权限**:
     - ✅ `workflow` - 允许触发 GitHub Actions
     - ✅ `repo` - 访问仓库（如果是私有仓库）
   - 点击 "Generate token"
   - **重要**: 立即复制保存 token！

3. **使用新 Token**
   ```bash
   export GH_TOKEN="your_new_token_here"
   gh workflow run build.yml -f tag="r1.8.0_ms2.7.2_cann8.5.0_py3.11"
   ```

### 方法 2：通过网页直接触发（推荐）

如果您已经登录 GitHub：

1. **访问 Actions 页面**
   ```
   https://github.com/JavaZeroo/mindformers-dockerfile/actions/workflows/build.yml
   ```

2. **触发工作流**
   - 点击右上角绿色 "Run workflow" 按钮
   - 选择分支: `copilot/debug-dockerfile-error` 或 `master`
   - 填写 tag: `r1.8.0_ms2.7.2_cann8.5.0_py3.11`
   - 勾选 publish 和 sync_swr（如需要）
   - 点击绿色 "Run workflow" 按钮

3. **查看运行结果**
   - 刷新页面，新的运行会出现在列表中
   - 点击运行查看实时日志
   - 可以查看各个步骤的详细输出

### 方法 3：使用 API 触发（高级）

如果有有效的 token：

```bash
TOKEN="your_valid_token"

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

## 监控运行结果

### 使用 GitHub CLI（需要有效 token）

```bash
# 设置 token
export GH_TOKEN="your_valid_token"

# 触发工作流
gh workflow run build.yml \
  -f tag="r1.8.0_ms2.7.2_cann8.5.0_py3.11" \
  -f publish=true \
  -f sync_swr=true

# 列出最近的运行
gh run list --workflow=build.yml --limit 5

# 查看特定运行的状态（替换 RUN_ID）
gh run view RUN_ID

# 实时查看日志
gh run watch RUN_ID

# 查看失败的日志
gh run view RUN_ID --log-failed
```

### 使用网页监控

1. **查看所有运行**
   ```
   https://github.com/JavaZeroo/mindformers-dockerfile/actions
   ```

2. **查看特定工作流**
   ```
   https://github.com/JavaZeroo/mindformers-dockerfile/actions/workflows/build.yml
   ```

3. **运行详情**
   - 点击任何运行查看详细信息
   - 展开步骤查看日志
   - 下载日志文件（如需要）
   - 重新运行失败的作业

## 预期结果

### 成功的运行应该显示：

```
✅ prepare - 准备构建矩阵
✅ build - 构建 Docker 镜像
  ├─ Free Disk Space - 清理磁盘（~2分钟）
  ├─ Check disk space - 验证空间
  ├─ Build image - 构建镜像（~30-40分钟）
  │  ├─ Stage 1: Install Python
  │  ├─ Stage 2: Install CANN
  │  └─ Stage 3: Final image
  └─ Upload image artifact - 上传镜像
✅ push - 推送镜像（如果启用）
✅ sync - 同步到 SWR（如果启用）
```

### 时间估算

- **总时间**: 约 30-45 分钟
- **准备阶段**: 1-2 分钟
- **磁盘清理**: 2-3 分钟
- **Docker 构建**: 25-35 分钟
- **推送镜像**: 3-5 分钟

### 常见错误

1. **磁盘空间不足**
   - 已通过 `free-disk-space` action 解决
   - 构建前释放 ~14GB 空间

2. **网络超时**
   - 下载 CANN/MindSpore 时可能发生
   - 解决方案：重新运行工作流

3. **构建失败**
   - 查看详细日志找出原因
   - 常见原因：依赖下载失败、编译错误

## 快速命令参考

```bash
# 检查当前 token
gh auth status

# 使用新 token 登录
echo "YOUR_TOKEN" | gh auth login --with-token

# 触发构建
gh workflow run build.yml -f tag="r1.8.0_ms2.7.2_cann8.5.0_py3.11"

# 查看最新运行
gh run list --workflow=build.yml --limit 1

# 获取最新运行 ID
LATEST_RUN=$(gh run list --workflow=build.yml --limit 1 --json databaseId --jq '.[0].databaseId')

# 实时监控
gh run watch $LATEST_RUN

# 查看日志
gh run view $LATEST_RUN --log
```

## 下一步

1. ✅ 创建有效的 GitHub Personal Access Token
2. ✅ 使用网页或 CLI 触发工作流
3. ✅ 监控运行进度
4. ✅ 查看构建结果
5. ✅ 如成功，拉取并使用镜像

---

**如果需要帮助，请查看：**
- [TRIGGER_GITHUB_ACTIONS.md](./TRIGGER_GITHUB_ACTIONS.md) - 完整触发指南
- [GITHUB_ACTIONS_QUICKSTART.md](./GITHUB_ACTIONS_QUICKSTART.md) - 快速开始
