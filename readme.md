# train 容器

```bash
docker build --network host -t swr.cn-central-221.ovaijisuan.com/mindformers/deepseek_v3_mindspore2.4.10-train:20250209 -f Dockerfile . && docker push swr.cn-central-221.ovaijisuan.com/mindformers/deepseek_v3_mindspore2.4.10-train:20250209
```

# infer 容器

```bash
cd packages
nohup python -m http.server &
cd ..


docker build --network host -t swr.cn-central-221.ovaijisuan.com/mindformers/deepseek_v3_mindspore2.5.0-infer:20250209 -f Dockerfile_offline . && docker push swr.cn-central-221.ovaijisuan.com/mindformers/deepseek_v3_mindspore2.5.0-infer:20250209
```