# MindFormers Dockerfile —— AI 编码助手必读指南

> 本文件面向 AI 编码助手（Agent）。如果你对这个项目一无所知，请从本节开始阅读。

---

## 项目概述

本项目是一个 **Docker 镜像构建仓库**，专门用于为华为昇腾（Ascend）平台打包 MindFormers 训练环境。它不提供 MindFormers 本身的源代码，而是提供一系列 Dockerfile 和版本配置文件，自动化构建包含以下组件的容器镜像：

- **Python**：从源码编译安装（如 3.11.4），安装在 `/usr/local/python${PYTHON_VERSION}`。
- **CANN**（Compute Architecture for Neural Networks）：华为昇腾 AI 软件栈，包括 Toolkit（开发套件）和 Kernels/Ops（算子包）。
- **MindSpore**：华为深度学习框架的 aarch64 wheel 包。
- **MindFormers**：基于 MindSpore 的大模型训练框架，从 Gitee/GitCode 克隆并在镜像构建时编译安装。

基础镜像统一使用 `ubuntu:24.04`，目标平台为 `linux/aarch64`（ARM64）。

---

## 仓库结构与关键文件

```
.
├── versions.json              # 版本配置总表：标签 -> build-arg 映射
├── Dockerfile.base            # 标准生产镜像（3 阶段构建）
├── Dockerfile.dev             # 开发版镜像，额外包含编辑器、调试器、AI 工具等
├── Dockerfile.uv              # 使用 uv 替代 pip 的高速包管理版本
├── Dockerfile                 # 主力构建镜像，标准 CANN 8.5+ 版本
├── README.md                  # 面向人类用户的使用说明（中文）
├── LICENSE                    # Apache License 2.0
├── .github/workflows/         # GitHub Actions CI/CD 工作流
│   ├── build.yml              # 标准镜像自动构建/推送
│   ├── build-manual.yml       # 手动触发构建（标准版）
│   ├── build-uv.yml           # uv 版本自动构建/推送
│   └── build-uv-manual.yml    # 手动触发构建（uv 版）
└── experimental/              # 历史/实验性 Dockerfile
    ├── Dockerfile.base.noroot
    ├── Dockerfile.base.cutomuser
    ├── Dockerfile.r1.3.0
    ├── Dockerfile.r1.5.0
    ├── Dockerfile.py311.new
    └── ...
```

### `versions.json` 的作用

这是本仓库的**核心配置文件**。每个键是一个版本标签（如 `r1.8.0_ms2.7.2_cann8.5.0_py3.11`），对应的值包含构建参数：

- `DOCKERFILE`：指定使用哪个 Dockerfile（如 `Dockerfile.base` 或 `Dockerfile`）
- `PYTHON_VERSION`：Python 版本号（如 `3.11.4`）
- `CANN_TOOLKIT_URL`：CANN Toolkit 安装包下载地址
- `CANN_KERNELS_URL`：CANN Kernels/Ops 安装包下载地址
- `MS_WHL_URL`：MindSpore wheel 包下载地址
- `MINDFORMERS_GIT_REF`：MindFormers 仓库的分支或标签（如 `r1.8.0`）

**本地构建示例**：

```bash
VERSION=r1.8.0_ms2.7.2_cann8.5.0_py3.11
docker build --network host -t mindformers:${VERSION} \
  $(jq -r ".\"${VERSION}\" | to_entries | .[] | \" --build-arg \\(.key)=\\(.value)\"" versions.json) \
  -f $(jq -r ".\"${VERSION}\".DOCKERFILE" versions.json) .
```

---

## 构建流程与架构

所有 Dockerfile 均采用**多阶段构建（multi-stage）**，典型分为 3 个阶段：

1. **`python-installer`**：
   - 安装编译依赖（`build-essential`、`libssl-dev` 等）。
   - 从华为云镜像 `repo.huaweicloud.com/python` 下载 Python 源码并编译安装。
   - 启用 shared library、optimizations、sqlite extensions。

2. **`cann-installer`**（基于 `python-installer`）：
   - 下载 CANN Toolkit 和 Kernels/Ops 安装包（需带 `Referer: https://www.hiascend.com/` 请求头）。
   - 执行 `.run` 安装包，使用 `--quiet --install --install-for-all` 参数静默安装。

3. **`final` / `official-ubuntu`**：
   - 从 `ubuntu:24.04` 重新开始，保持最终镜像相对干净。
   - `COPY` 上一阶段的 Python 和 `/usr/local/Ascend`。
   - 设置大量环境变量（`LD_LIBRARY_PATH`、`PYTHONPATH`、`ASCEND_TOOLKIT_HOME` 等）。
   - 使用阿里云 PyPI 镜像安装 `sympy`、CANN 的 `te`/`hccl` wheel、MindSpore wheel。
   - 克隆 MindFormers 并执行 `bash build.sh` 编译安装。
   - 编译 `mindformers/dataset/blended_datasets` 下的 C++ 扩展。
   - 配置 `.bashrc`（Ascend 环境初始化、时区、中文 banner 等）。

### 各 Dockerfile 的区别

| Dockerfile | 用途 | 关键差异 |
|-----------|------|---------|
| `Dockerfile.base` | 标准生产镜像 | 最小化依赖，仅包含运行所需组件 |
| `Dockerfile.dev` | 开发调试镜像 | 额外安装 `neovim`、`gdb`、`pytest`、`pre-commit`、`git-lfs`、`aria2c`、`hfd.sh`、OpenCode、Cursor CLI 等 |
| `Dockerfile.uv` | 高速包管理版本 | 使用 `astral-sh/uv` 替代 `pip`，大幅提升 Python 包安装速度 |
| `Dockerfile` | 主力构建镜像 | 项目当前主力 Dockerfile，专为 CANN 8.5+ 设计；算子包名称为 `Ascend-cann-ops.run`，环境变量路径指向 `cann-8.5.0`，并增加 `gitcode.com` 源码仓库支持 |

---

## CI/CD 与部署

GitHub Actions 工作流托管在 `.github/workflows/` 中，运行环境为 `ubuntu-24.04-arm`（ARM64 原生 Runner）。

### 自动化触发条件

- 向 `work` 分支推送时，若修改了 `versions.json`、对应的 Dockerfile 或工作流文件，会自动触发构建。

### 镜像分发目标

构建成功的镜像会同时推送到：

- **Docker Hub**：`{DOCKERHUB_USERNAME}/mindformers:{tag}`
- **华为 SWR**：`swr.cn-central-221.ovaijisuan.com/{SWR_ORG}/mindformers:{tag}`

### 工作流说明

- **`build.yml`**：标准构建流程。分为 `prepare`（生成矩阵）、`build`（构建并保存 tar  artifact）、`push`（推送到 Docker Hub）、`sync`（同步到华为 SWR）。
- **`build-manual.yml`**：手动触发，可自定义所有 build-arg 和 Dockerfile。
- **`build-uv.yml` / `build-uv-manual.yml`**：与上述对应，但使用 `Dockerfile.uv` 构建，镜像标签后缀为 `-uv`。

### Secrets 依赖

工作流依赖以下 GitHub Secrets：

- `DOCKERHUB_USERNAME` / `DOCKERHUB_TOKEN`
- `SWR_USERNAME` / `SWR_PASSWORD`
- `SWR_ORG`

---

## 开发约定与代码风格

### 语言与注释

- 项目文档（`README.md`）和 Dockerfile 中的注释以**中文为主**，夹杂英文技术术语。
- 新增注释应保持原有风格：在关键步骤前加 `# ================================` 分隔线，并用中文简要说明阶段目的。

### 镜像内网络与镜像源配置

为适配中国大陆网络环境，镜像内默认配置了以下镜像源：

- Python 源码：`https://repo.huaweicloud.com/python/`
- PyPI：`https://mirrors.aliyun.com/pypi/simple`
- Hugging Face：`https://hf-mirror.com`（通过 `HF_ENDPOINT` 环境变量）

同时，为了规避某些场景下的 SSL 证书问题，镜像构建过程中**禁用了部分 SSL 校验**：

```dockerfile
RUN git config --global http.sslverify false \
    && echo "check_certificate = off" >> ~/.wgetrc
```

> **注意**：这是出于构建成功率考虑的权衡，修改相关逻辑时应评估安全风险。

### 时区与 locale

- 时区固定为 `Asia/Shanghai`
- locale 固定为 `C.UTF-8`

### `.bashrc` 定制

每个 Dockerfile 都会向 `/root/.bashrc` 追加：

- `export GLOG_v=2`
- `source /usr/local/Ascend/ascend-toolkit/set_env.sh`（CANN 环境初始化）
- MindFormers ASCII Art Banner（绿色字体）
- `Dockerfile.dev` 中还会追加开发工具提示信息

---

## 测试说明

**本仓库本身不包含单元测试代码**。验证构建是否成功的常规方式是：

1. 启动容器：
   ```bash
   docker run --rm -it mindformers:{tag} bash
   ```
2. 在容器内执行基础导入检查：
   ```bash
   python -c "import mindspore; print(mindspore.__version__)"
   python -c "import mindformers; print(mindformers.__version__)"
   ```
3. 如有昇腾硬件环境，可进一步运行 `npu-smi info` 或 MindFormers 自带示例脚本验证训练/推理链路。

---

## 安全注意事项

1. **根用户运行**：`Dockerfile.base`、`Dockerfile.uv`、`Dockerfile` 均默认以 `root` 用户运行。如果需要非 root 环境，请参考 `experimental/Dockerfile.base.noroot` 或 `experimental/Dockerfile.base.cutomuser`。
2. **SSL 校验关闭**：构建过程中全局关闭了 `git sslverify` 和 `wget` 证书校验，便于在受限网络下下载资源，但会引入中间人攻击风险。若用于生产环境对外发布，应评估是否恢复校验。
3. **CANN 安装权限**：使用 `--install-for-all` 参数安装 CANN，意味着所有用户均可访问昇腾工具链。
4. ** Secrets 泄露风险**：不要在 Dockerfile 中硬编码任何下载 URL 的认证信息或私有 token。

---

## 常见问题（Agent 须知）

- **为什么 Python 要从源码编译？**  
  因为 CANN 和 MindSpore 对 Python 版本和编译选项（如 `--enable-shared`）有严格要求，使用 Ubuntu 系统自带 Python 容易导致 ABI 不兼容。

- **CANN 下载为什么要加 `Referer`？**  
  华为昇腾软件源对直接 wget/curl 有反盗链策略，必须携带 `Referer: https://www.hiascend.com/` 请求头。

- **`experimental/` 里的 Dockerfile 还能用吗？**  
  这些文件多为历史版本（如 `r1.3.0`、`r1.5.0`）或特殊定制（如 `noroot`、`modelarts`、`glm`、`qwen3`），除非有明确兼容性需求，否则新增版本应在根目录的 `Dockerfile.base` / `Dockerfile` / `Dockerfile.uv` 上迭代。

- **如何新增一个版本？**  
  1. 在 `versions.json` 中新增一个条目，填写正确的 URL 和 Git 引用。
  2. 根据 CANN 版本选择对应的 `DOCKERFILE`（8.5 及以上用 `Dockerfile`，其余用 `Dockerfile.base`）。
  3. 提交并推送到 `work` 分支，CI 会自动构建。
