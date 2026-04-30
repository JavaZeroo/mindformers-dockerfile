# ================================
# Configuration for MindFormers Dockerfile (CANN 8.5)
# ================================
ARG PYTHON_VERSION
ARG CANN_TOOLKIT_URL
ARG CANN_KERNELS_URL
ARG MS_WHL_URL
ARG MINDFORMERS_GIT_REF

# ================================
# Stage 1: Install Python
# ================================
FROM ubuntu:24.04 AS python-installer

ARG PYTHON_VERSION

# Python Environment variables
ENV PATH=/usr/local/python${PYTHON_VERSION}/bin:${PATH}

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    apt-transport-https ca-certificates bash curl build-essential \
    libssl-dev zlib1g-dev libncurses5-dev libbz2-dev libreadline-dev \
    libsqlite3-dev libffi-dev libnss3-dev libgdbm-dev liblzma-dev \
    libev-dev wget && apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

WORKDIR /tmp

# Install Python
RUN wget -q https://repo.huaweicloud.com/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz -O /tmp/Python-${PYTHON_VERSION}.tgz && \
    tar -xf /tmp/Python-${PYTHON_VERSION}.tgz -C /tmp && \
    cd /tmp/Python-${PYTHON_VERSION} && \
    mkdir -p /usr/local/python${PYTHON_VERSION}/lib && \
    ./configure --enable-shared --enable-shared LDFLAGS="-Wl,-rpath /usr/local/python${PYTHON_VERSION}/lib" --prefix=/usr/local/python${PYTHON_VERSION} --enable-optimizations --enable-loadable-sqlite-extensions && \
    make -j $(nproc) && \
    make altinstall && \
    PYTHON_SHORT_VERSION=$(echo ${PYTHON_VERSION} | awk -F. '{print $1"."$2}') && \
    ln -sf /usr/local/python${PYTHON_VERSION}/bin/python${PYTHON_SHORT_VERSION}-config /usr/local/python${PYTHON_VERSION}/bin/python3-config && \
    ln -sf /usr/local/python${PYTHON_VERSION}/bin/python${PYTHON_SHORT_VERSION} /usr/local/python${PYTHON_VERSION}/bin/python3 && \
    ln -sf /usr/local/python${PYTHON_VERSION}/bin/pip${PYTHON_SHORT_VERSION} /usr/local/python${PYTHON_VERSION}/bin/pip3 && \
    ln -sf /usr/local/python${PYTHON_VERSION}/bin/python3 /usr/local/python${PYTHON_VERSION}/bin/python && \
    ln -sf /usr/local/python${PYTHON_VERSION}/bin/pip3 /usr/local/python${PYTHON_VERSION}/bin/pip && \
    rm -rf /tmp/*

# ================================
# Stage 2: Install CANN
# ================================
FROM python-installer AS cann-installer

ARG CANN_TOOLKIT_URL
ARG CANN_KERNELS_URL

RUN apt-get update && apt-get install --no-install-recommends -y \
        git \
        wget \
        gcc \
        g++ \
        make \
        cmake \
        zlib1g \
        openssl \
        unzip \
        pciutils \
        net-tools \
        libblas-dev \
        gfortran \
        patchelf \
        libblas3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Note: Install CANN runtime dependencies
RUN pip install --no-cache-dir --upgrade pip

# Note: Get the download link according to ARCH and download the installation package
RUN wget -q --header="Referer: https://www.hiascend.com/" ${CANN_TOOLKIT_URL} -O ~/Ascend-cann-toolkit.run && \
    wget -q --header="Referer: https://www.hiascend.com/" ${CANN_KERNELS_URL} -O ~/Ascend-cann-ops.run

# Note: Install CANN Toolkit Development Kit Package
RUN chmod +x ~/Ascend-cann-toolkit.run && \
    ~/Ascend-cann-toolkit.run --quiet --install --install-for-all && \
    rm -f ~/Ascend-cann-toolkit.run

# Note: Install CANN Ops Operator Package
RUN chmod +x ~/Ascend-cann-ops.run && \
    ~/Ascend-cann-ops.run --quiet --install --install-for-all && \
    rm -f ~/Ascend-cann-ops.run

# ================================
# Stage 3: Final image
# ================================
FROM ubuntu:24.04 AS official-ubuntu

ARG MS_WHL_URL
ARG PYTHON_VERSION

# Python Environment variables
ENV PATH=/usr/local/python${PYTHON_VERSION}/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/python${PYTHON_VERSION}/lib:${LD_LIBRARY_PATH}

# Note: Toolkit Environment variables, obtained from /usr/local/Ascend/ascend-toolkit/set_env.sh
ENV ASCEND_TOOLKIT_HOME=/usr/local/Ascend/cann-8.5.0
ENV ASCEND_TOOLKIT_LATEST_HOME=/usr/local/Ascend/ascend-toolkit/latest
ENV LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64:/usr/local/Ascend/driver/lib64/common/:/usr/local/Ascend/driver/lib64/driver/:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${ASCEND_TOOLKIT_HOME}/lib64:${ASCEND_TOOLKIT_HOME}/lib64/plugin/opskernel:${ASCEND_TOOLKIT_HOME}/lib64/plugin/nnengine:${ASCEND_TOOLKIT_HOME}/opp/built-in/op_impl/ai_core/tbe/op_tiling:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${ASCEND_TOOLKIT_HOME}/tools/aml/lib64:${ASCEND_TOOLKIT_HOME}/tools/aml/lib64/plugin:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${ASCEND_TOOLKIT_LATEST_HOME}/lib64:${ASCEND_TOOLKIT_LATEST_HOME}/lib64/plugin/opskernel:${ASCEND_TOOLKIT_LATEST_HOME}/lib64/plugin/nnengine:${ASCEND_TOOLKIT_LATEST_HOME}/opp/built-in/op_impl/ai_core/tbe/op_tiling:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${ASCEND_TOOLKIT_LATEST_HOME}/tools/aml/lib64:${ASCEND_TOOLKIT_LATEST_HOME}/tools/aml/lib64/plugin:$LD_LIBRARY_PATH
ENV PYTHONPATH=${ASCEND_TOOLKIT_HOME}/python/site-packages:${ASCEND_TOOLKIT_HOME}/opp/built-in/op_impl/ai_core/tbe:$PYTHONPATH
ENV PYTHONPATH=${ASCEND_TOOLKIT_LATEST_HOME}/python/site-packages:${ASCEND_TOOLKIT_LATEST_HOME}/opp/built-in/op_impl/ai_core/tbe:$PYTHONPATH
ENV PATH=${ASCEND_TOOLKIT_HOME}/bin:${ASCEND_TOOLKIT_HOME}/tools/ccec_compiler/bin:${ASCEND_TOOLKIT_HOME}/tools/profiler/bin:${ASCEND_TOOLKIT_HOME}//tools/ascend_system_advisor/asys:$PATH
ENV PATH=${ASCEND_TOOLKIT_HOME}/tools/show_kernel_debug_data:${ASCEND_TOOLKIT_HOME}/tools/msobjdump:$PATH
ENV PATH=${ASCEND_TOOLKIT_LATEST_HOME}/bin:${ASCEND_TOOLKIT_LATEST_HOME}/compiler/ccec_compiler/bin:${ASCEND_TOOLKIT_LATEST_HOME}/tools/ccec_compiler/bin:$PATH
ENV ASCEND_AICPU_PATH=${ASCEND_TOOLKIT_HOME}
ENV ASCEND_OPP_PATH=${ASCEND_TOOLKIT_HOME}/opp
ENV TOOLCHAIN_HOME=${ASCEND_TOOLKIT_HOME}/toolkit
ENV ASCEND_HOME_PATH=${ASCEND_TOOLKIT_HOME}

SHELL [ "/bin/bash", "-c" ]

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    apt-transport-https ca-certificates bash libc6 libsqlite3-dev gcc g++ make cmake git \
    vim wget jq libncurses5-dev curl build-essential libnuma-dev zip net-tools iputils-ping iproute2 openssh-server \
    tcl patch flex autoconf automake libtool libssl-dev zlib1g-dev \
    libffi-dev libbz2-dev libreadline-dev libncursesw5-dev tk-dev liblzma-dev \
    jq libblas-dev gfortran libblas3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

COPY --from=cann-installer /usr/local/python${PYTHON_VERSION} /usr/local/python${PYTHON_VERSION}
COPY --from=cann-installer /usr/local/Ascend /usr/local/Ascend
COPY --from=cann-installer /etc/Ascend /etc/Ascend

RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple && \
    pip install sympy absl-py cloudpickle ml-dtypes tornado "decorator>=5.1.0" "dill==0.3.8" && \
    pip install ${MS_WHL_URL} --trusted-host repo.mindspore.cn && rm -rf ~/.cache/pip

WORKDIR /home/work
RUN git clone https://gitcode.com/mindspore/mindformers.git && \
    cd mindformers && \
    git checkout ${MINDFORMERS_GIT_REF} || exit 1 && \
    git show && \
    sed -i 's|pip install mindformers\*whl -i https://pypi.tuna.tsinghua.edu.cn/simple|pip install mindformers\*whl|g' build.sh && \
    bash build.sh && \
    pip install pybind11 pytest ruff && \
    cd mindformers/dataset/blended_datasets && make && \
    cd /home/work && \
    git clone https://gitcode.com/mindspore/hyper-parallel.git && \
    cd hyper-parallel && \
    pip install -e . && \
    rm -rf ~/.cache/pip

RUN echo "export GLOG_v=2" >> /root/.bashrc \
    && echo "source /usr/local/Ascend/ascend-toolkit/set_env.sh" >> /root/.bashrc \
    && echo "source /usr/local/Ascend/cann-8.5.0/share/info/ascendnpu-ir/bin/set_env.sh" >> /root/.bashrc \
    && printf "%s\n" \
    "echo ''" \
    "cat << 'EOF'" \
    " ███╗   ███╗██╗███╗   ██╗██████╗ ███████╗ ██████╗ ██████╗ ███╗   ███╗███████╗██████╗ ███████╗" \
    " ████╗ ████║██║████╗  ██║██╔══██╗██╔════╝██╔═══██╗██╔══██╗████╗ ████║██╔════╝██╔══██╗██╔════╝" \
    " ██╔████╔██║██║██╔██╗ ██║██║  ██║█████╗  ██║   ██║██████╔╝██╔████╔██║█████╗  ██████╔╝███████╗" \
    " ██║╚██╔╝██║██║██║╚██╗██║██║  ██║██╔══╝  ██║   ██║██╔══██╗██║╚██╔╝██║██╔══╝  ██╔══██╗╚════██║" \
    " ██║ ╚═╝ ██║██║██║ ╚████║██████╔╝██║     ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗██║  ██║███████║" \
    " ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝" \
    "EOF" >> /root/.bashrc

# 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' > /etc/timezone
# 设置语言环境
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 PYTHONIOENCODING=utf-8