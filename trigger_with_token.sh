#!/bin/bash
# Token 诊断和工作流触发脚本

set -e

echo "════════════════════════════════════════════════════════════"
echo "  GitHub Actions 工作流触发工具"
echo "════════════════════════════════════════════════════════════"
echo ""

VERSION="r1.8.0_ms2.7.2_cann8.5.0_py3.11"

# 检查是否提供了 token
if [ -z "$1" ]; then
    echo "❌ 错误: 未提供 token"
    echo ""
    echo "用法: $0 <github_token>"
    echo ""
    echo "示例: $0 ghp_xxxxxxxxxxxxxxxxxxxx"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "如何获取 token:"
    echo "  1. 访问 https://github.com/settings/tokens"
    echo "  2. 点击 'Generate new token (classic)'"
    echo "  3. 选择权限: workflow, repo"
    echo "  4. 生成并复制 token"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
fi

TOKEN="$1"
export GH_TOKEN="$TOKEN"

echo "🔍 步骤 1: 验证 token..."
echo ""

# 验证 token
if gh auth status &> /dev/null; then
    echo "✅ Token 有效"
    gh auth status 2>&1 | head -5
else
    echo "❌ Token 无效或已过期"
    echo ""
    echo "可能的原因："
    echo "  • Token 已过期"
    echo "  • Token 权限不足（需要 'workflow' 权限）"
    echo "  • Token 已被撤销"
    echo ""
    echo "请访问 https://github.com/settings/tokens 创建新的 token"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 步骤 2: 触发工作流..."
echo ""
echo "版本: $VERSION"
echo "工作流: build.yml"
echo ""

# 触发工作流
if gh workflow run build.yml \
    -f tag="$VERSION" \
    -f publish=true \
    -f sync_swr=true; then
    echo ""
    echo "✅ 工作流已成功触发！"
else
    echo ""
    echo "❌ 触发失败"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⏳ 步骤 3: 等待工作流启动..."
sleep 5

echo ""
echo "📊 步骤 4: 获取运行状态..."
echo ""

# 获取最新运行
RUNS=$(gh run list --workflow=build.yml --limit 3 --json databaseId,status,conclusion,displayTitle,createdAt,url)

if [ -z "$RUNS" ] || [ "$RUNS" == "[]" ]; then
    echo "⚠️  未找到运行记录，请稍后手动查看"
    echo ""
    echo "访问: https://github.com/JavaZeroo/mindformers-dockerfile/actions"
else
    echo "$RUNS" | jq -r '.[] | "ID: \(.databaseId) | 状态: \(.status) | \(.displayTitle)"' | head -3
    echo ""
    
    # 获取最新的运行 ID
    LATEST_RUN=$(echo "$RUNS" | jq -r '.[0].databaseId')
    RUN_URL=$(echo "$RUNS" | jq -r '.[0].url')
    
    echo "最新运行 ID: $LATEST_RUN"
    echo "运行 URL: $RUN_URL"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 后续操作"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "查看所有运行:"
echo "  gh run list --workflow=build.yml"
echo ""
echo "查看最新运行详情:"
if [ -n "$LATEST_RUN" ]; then
    echo "  gh run view $LATEST_RUN"
    echo ""
    echo "实时监控日志:"
    echo "  gh run watch $LATEST_RUN"
fi
echo ""
echo "或访问网页:"
echo "  https://github.com/JavaZeroo/mindformers-dockerfile/actions"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⏱️  预计构建时间: 30-45 分钟"
echo ""
