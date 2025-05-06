# 构建镜像

```bash
docker build --network host -t mindformers-dev-mindspore-2.5.0-910b-py3.10:20250428 --build-arg TARGETPLATFORM=linux/arm64 -f Dockerfile.py311.new .
```