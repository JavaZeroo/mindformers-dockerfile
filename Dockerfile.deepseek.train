# base on ubuntu 22.04 arm
FROM ubuntu:arm_22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN chmod 777 /tmp \
  && buildDeps='gcc g++ make vim wget curl zip net-tools iputils-ping iproute2 git python3-pip openssh-server tcl patch libnuma-dev flex autoconf automake libtool libssl-dev' \
  && apt-get update \
  && apt-get install -y $buildDeps \
  && git config --global http.sslverify false \
  && echo "check_certificate = off" >> ~/.wgetrc \
  && apt-get clean

# download and install cann
WORKDIR /root/packages
ARG cann_toolkit='https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.0.RC3/Ascend-cann-toolkit_8.0.RC3_linux-aarch64.run'
ARG cann_kernels='https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.0.RC3/Ascend-cann-kernels-910b_8.0.RC3_linux-aarch64.run'
ARG cann_nnal='https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.0.RC3/Ascend-cann-nnal_8.0.RC3_linux-aarch64.run'
ARG ascend_mindie='https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/MindIE/MindIE%201.0.RC3/Ascend-mindie_1.0.RC3_linux-aarch64.run'

RUN wget -q ${cann_toolkit} -O cann-toolkit.run && chmod +x cann-toolkit.run && ./cann-toolkit.run --full --quiet
RUN echo "export GLOG_v=2" >> /root/.bashrc \
  && echo "LOCAL_ASCEND=/usr/local/Ascend" >> /root/.bashrc \
  && echo "source ${LOCAL_ASCEND}/ascend-toolkit/set_env.sh" >> /root/.bashrc
RUN wget -q ${cann_kernels} -O cann-kernels.run && chmod +x cann-kernels.run && ./cann-kernels.run --install --quiet
RUN . /usr/local/Ascend/ascend-toolkit/set_env.sh \
  && wget -q ${cann_nnal} -O cann-nnal.run && chmod +x cann-nnal.run && ./cann-nnal.run --install --quiet || cat /var/log/ascend_seclog/ascend_nnal_install.log \
  && wget -q ${ascend_mindie} -O ascend_mindie.run && chmod +x ascend_mindie.run && ./ascend_mindie.run --install --quiet

# pip install process
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple \
  && pip config set install.trusted-host mirrors.aliyun.com \
  && pip install sympy \
  && pip install /usr/local/Ascend/ascend-toolkit/latest/lib64/te-*-py3-none-any.whl \
  && pip install /usr/local/Ascend/ascend-toolkit/latest/lib64/hccl-*-py3-none-any.whl \
  && pip install  https://ms-release.obs.cn-north-4.myhuaweicloud.com/2.4.10/MindSpore/unified/aarch64/mindspore-2.4.10-cp310-cp310-linux_aarch64.whl --trusted-host ms-release.obs.cn-north-4.myhuaweicloud.com

WORKDIR /root
RUN git clone -b dev https://gitee.com/mindspore/mindformers.git \
  && mkdir /home/work \
  && mv /root/mindformers /home/work \
  && ln -s /bin/python3 /bin/python \
  && cd /home/work/mindformers \
  && sed -i 's|pip install mindformers\*whl -i https://pypi.tuna.tsinghua.edu.cn/simple|pip install mindformers\*whl|g' build.sh \
  && bash build.sh \
  && pip install pybind11 \
  && cd mindformers/dataset/blended_datasets \
  && make 

RUN rm -rf ~/.cache/pip /root/packages/* /var/lib/apt/lists/*

ARG LOCAL_ASCEND=/usr/local/Ascend
RUN echo "export GLOG_v=2" >> /root/.bashrc \
  && echo "export LD_LIBRARY_PATH=${LOCAL_ASCEND}/driver/lib64/common:${LOCAL_ASCEND}/driver/lib64/driver:${LD_LIBRARY_PATH}" >> /root/.bashrc \
  && echo "source ${LOCAL_ASCEND}/driver/bin/setenv.bash" >> /root/.bashrc \
  && echo "source ${LOCAL_ASCEND}/ascend-toolkit/set_env.sh" >> /root/.bashrc \
  && echo "source ${LOCAL_ASCEND}/mindie/set_env.sh" >> /root/.bashrc \
  && echo "export MINDIE_LLM_FRAMEWORK_BACKEND=MS" >> /root/.bashrc \
  && echo "export MS_DEV_DYNAMIC_SINK1=False" >> /root/.bashrc \
  && echo "echo ''" >> /root/.bashrc \
  && echo "echo '   _____  .__            .______________                                       '" >> /root/.bashrc \
  && echo "echo '  /     \ |__| ____    __| _/\_   _____/__________  _____   ___________  ______'" >> /root/.bashrc \
  && echo "echo ' /  \ /  \|  |/    \  / __ |  |    __)/  _ \_  __ \/     \_/ __ \_  __ \/  ___/'" >> /root/.bashrc \
  && echo "echo '/    Y    \  |   |  \/ /_/ |  |     \(  <_> )  | \/  Y Y  \  ___/|  | \/\___ \ '" >> /root/.bashrc \
  && echo "echo ' \____|__  /__|___|  /\____ |  \___  / \____/|__|  |__|_|  /\___  >__|  /____  >'" >> /root/.bashrc \
  && echo "echo '        \/        \/      \/      \/                    \/     \/           \/ '" >> /root/.bashrc \
  && echo "echo ''" >> /root/.bashrc
