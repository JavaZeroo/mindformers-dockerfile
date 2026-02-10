#!/bin/bash
# Build script for MindFormers Docker images
# Usage: ./build_image.sh [version_tag]
# Example: ./build_image.sh r1.8.0_ms2.7.2_cann8.5.0_py3.11

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is not installed. Please install it first.${NC}"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    echo "  MacOS: brew install jq"
    exit 1
fi

# Check if versions.json exists
if [ ! -f "versions.json" ]; then
    echo -e "${RED}Error: versions.json not found in current directory${NC}"
    exit 1
fi

# Get version tag from argument or show available versions
VERSION_TAG="$1"

if [ -z "$VERSION_TAG" ]; then
    echo -e "${YELLOW}Available versions:${NC}"
    jq -r 'keys[]' versions.json
    echo ""
    echo -e "${YELLOW}Usage:${NC} $0 <version_tag>"
    echo -e "${YELLOW}Example:${NC} $0 r1.8.0_ms2.7.2_cann8.5.0_py3.11"
    exit 0
fi

# Check if version exists in versions.json
if ! jq -e --arg TAG "$VERSION_TAG" 'has($TAG)' versions.json > /dev/null; then
    echo -e "${RED}Error: Version '$VERSION_TAG' not found in versions.json${NC}"
    echo -e "${YELLOW}Available versions:${NC}"
    jq -r 'keys[]' versions.json
    exit 1
fi

echo -e "${GREEN}Building MindFormers Docker image for version: $VERSION_TAG${NC}"
echo ""

# Extract configuration from versions.json
DOCKERFILE=$(jq -r --arg TAG "$VERSION_TAG" '.[$TAG].DOCKERFILE // "Dockerfile.base"' versions.json)
PYTHON_VERSION=$(jq -r --arg TAG "$VERSION_TAG" '.[$TAG].PYTHON_VERSION' versions.json)
CANN_TOOLKIT_URL=$(jq -r --arg TAG "$VERSION_TAG" '.[$TAG].CANN_TOOLKIT_URL' versions.json)
CANN_KERNELS_URL=$(jq -r --arg TAG "$VERSION_TAG" '.[$TAG].CANN_KERNELS_URL' versions.json)
MS_WHL_URL=$(jq -r --arg TAG "$VERSION_TAG" '.[$TAG].MS_WHL_URL' versions.json)
MINDFORMERS_GIT_REF=$(jq -r --arg TAG "$VERSION_TAG" '.[$TAG].MINDFORMERS_GIT_REF' versions.json)

echo -e "${YELLOW}Configuration:${NC}"
echo "  Dockerfile: $DOCKERFILE"
echo "  Python Version: $PYTHON_VERSION"
echo "  CANN Toolkit: $CANN_TOOLKIT_URL"
echo "  CANN Kernels: $CANN_KERNELS_URL"
echo "  MindSpore: $MS_WHL_URL"
echo "  MindFormers Ref: $MINDFORMERS_GIT_REF"
echo ""

# Check if Dockerfile exists
if [ ! -f "$DOCKERFILE" ]; then
    echo -e "${RED}Error: Dockerfile '$DOCKERFILE' not found${NC}"
    exit 1
fi

# Image name
IMAGE_NAME="mindformers:${VERSION_TAG}"

echo -e "${GREEN}Starting Docker build...${NC}"
echo -e "${YELLOW}Image name: $IMAGE_NAME${NC}"
echo ""

# Build the Docker image
docker build \
    --network host \
    -f "$DOCKERFILE" \
    --build-arg PYTHON_VERSION="$PYTHON_VERSION" \
    --build-arg CANN_TOOLKIT_URL="$CANN_TOOLKIT_URL" \
    --build-arg CANN_KERNELS_URL="$CANN_KERNELS_URL" \
    --build-arg MS_WHL_URL="$MS_WHL_URL" \
    --build-arg MINDFORMERS_GIT_REF="$MINDFORMERS_GIT_REF" \
    -t "$IMAGE_NAME" \
    .

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Build completed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}To run the image:${NC}"
    echo "  docker run --rm -it $IMAGE_NAME bash"
    echo ""
    echo -e "${YELLOW}To save the image to a tar file:${NC}"
    echo "  docker save $IMAGE_NAME -o mindformers-${VERSION_TAG}.tar"
    echo ""
    echo -e "${YELLOW}Image details:${NC}"
    docker images "$IMAGE_NAME" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
else
    echo ""
    echo -e "${RED}✗ Build failed!${NC}"
    exit 1
fi
