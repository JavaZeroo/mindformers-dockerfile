#!/bin/bash
# Script to trigger GitHub Actions workflow for building Docker images
# Requires GitHub CLI (gh) to be installed and authenticated

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  MindFormers Docker Image Build - GitHub Actions      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed.${NC}"
    echo ""
    echo "Please install it first:"
    echo "  Ubuntu/Debian: sudo apt install gh"
    echo "  MacOS: brew install gh"
    echo "  Or visit: https://cli.github.com/"
    echo ""
    echo -e "${YELLOW}Alternative: You can manually trigger the workflow at:${NC}"
    echo "  https://github.com/JavaZeroo/mindformers-dockerfile/actions/workflows/build.yml"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}GitHub CLI is not authenticated. Running authentication...${NC}"
    gh auth login
fi

# Get version tag
VERSION_TAG="$1"

if [ -z "$VERSION_TAG" ]; then
    echo -e "${YELLOW}Available versions in versions.json:${NC}"
    if command -v jq &> /dev/null && [ -f "versions.json" ]; then
        jq -r 'keys[]' versions.json | sed 's/^/  /'
    else
        echo "  r1.8.0_ms2.7.2_cann8.5.0_py3.11"
        echo "  r1.7.0_ms2.7.1_cann8.3.RC1_py3.11"
        echo "  r1.6.0_ms2.7.0_cann8.2.RC1_py3.11"
    fi
    echo ""
    echo -e "${YELLOW}Usage:${NC} $0 <version_tag> [--no-publish] [--no-sync]"
    echo -e "${YELLOW}Example:${NC} $0 r1.8.0_ms2.7.2_cann8.5.0_py3.11"
    exit 0
fi

# Parse options
PUBLISH="true"
SYNC_SWR="true"

for arg in "$@"; do
    case $arg in
        --no-publish)
            PUBLISH="false"
            ;;
        --no-sync)
            SYNC_SWR="false"
            ;;
    esac
done

echo -e "${GREEN}Configuration:${NC}"
echo "  Version Tag: $VERSION_TAG"
echo "  Publish to Docker Hub: $PUBLISH"
echo "  Sync to Huawei SWR: $SYNC_SWR"
echo ""

# Confirm
echo -e "${YELLOW}This will trigger a GitHub Actions workflow to build the Docker image.${NC}"
echo -e "${YELLOW}The build process will take approximately 30-45 minutes.${NC}"
echo ""
read -p "Do you want to continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}Triggering GitHub Actions workflow...${NC}"

# Trigger the workflow
gh workflow run build.yml \
    -f tag="$VERSION_TAG" \
    -f publish="$PUBLISH" \
    -f sync_swr="$SYNC_SWR"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Workflow triggered successfully!${NC}"
    echo ""
    echo -e "${YELLOW}To monitor the workflow:${NC}"
    echo "  gh workflow view build.yml --web"
    echo ""
    echo "Or visit:"
    echo "  https://github.com/JavaZeroo/mindformers-dockerfile/actions"
    echo ""
    
    # Wait a moment and try to get the run URL
    sleep 3
    echo -e "${YELLOW}Fetching workflow run...${NC}"
    gh run list --workflow=build.yml --limit 1
else
    echo ""
    echo -e "${RED}✗ Failed to trigger workflow!${NC}"
    echo ""
    echo -e "${YELLOW}You can manually trigger it at:${NC}"
    echo "  https://github.com/JavaZeroo/mindformers-dockerfile/actions/workflows/build.yml"
    exit 1
fi
