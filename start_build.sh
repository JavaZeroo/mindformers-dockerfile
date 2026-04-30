#!/bin/bash
# Quick script to trigger GitHub Actions build for r1.8.0_ms2.7.2_cann8.5.0_py3.11

set -e

VERSION="r1.8.0_ms2.7.2_cann8.5.0_py3.11"

echo "════════════════════════════════════════════════════════════"
echo "  触发 GitHub Actions 构建"
echo "  版本: $VERSION"
echo "════════════════════════════════════════════════════════════"
echo ""

# Check if gh is installed and authenticated
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null 2>&1; then
        echo "✓ GitHub CLI 已认证"
        echo ""
        echo "正在触发工作流..."
        echo ""
        
        gh workflow run build.yml \
          -f tag="$VERSION" \
          -f publish=true \
          -f sync_swr=true
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✓ 工作流已成功触发！"
            echo ""
            echo "查看状态："
            echo "  gh run list --workflow=build.yml --limit 5"
            echo ""
            echo "或访问网页："
            echo "  https://github.com/JavaZeroo/mindformers-dockerfile/actions"
            exit 0
        else
            echo ""
            echo "✗ 触发失败"
            exit 1
        fi
    fi
fi

# Fallback to manual instructions
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  无法自动触发 - 请手动操作"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "方法 1: 使用网页（推荐）"
echo ""
echo "  1. 访问:"
echo "     https://github.com/JavaZeroo/mindformers-dockerfile/actions/workflows/build.yml"
echo ""
echo "  2. 点击 'Run workflow' 按钮"
echo ""
echo "  3. 填写参数:"
echo "     - tag: $VERSION"
echo "     - publish: ✓"
echo "     - sync_swr: ✓"
echo ""
echo "  4. 点击绿色 'Run workflow' 按钮"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "方法 2: 安装 GitHub CLI"
echo ""
echo "  Ubuntu/Debian: sudo apt install gh"
echo "  MacOS: brew install gh"
echo ""
echo "  然后运行: gh auth login"
echo "  再次执行此脚本"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "详细文档: TRIGGER_GITHUB_ACTIONS.md"
echo ""

