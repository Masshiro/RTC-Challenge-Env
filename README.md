# Challenge Environment

This repository provides a container of the runtime environment for challenge https://2021.acmmmsys.org/rtc_challenge.php. It includes the RTC system, [AlphaRTC](https://github.com/OpenNetLab/AlphaRTC), and the evaluation system.

Because the challenge requires contestants to submit a bandwidth estimator for RTC system. Considering the tradeoff between resource limitation, efficiency and security, we will only provides pre-installed third-parties library in our challenge runtime environment that can be found at the [Dockerfile](dockers/Dockerfile).

If you want to add **more extensions** in the runtime environment, please create issue on this repository, we will discuss with OpenNetLab community about your proposal.

## Get the pre-provided docker image

```bash
docker pull opennetlab.azurecr.io/challenge-env
```

## Dockerfile provided by Zhiming

```bash
# Use Ubuntu 20.04 as the base image
FROM --platform=linux/amd64 ubuntu:20.04
ARG TARGETARCH
# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for WebRTC, depot_tools, and AlphaRTC
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    git \
    python3 \
    python3-pip \
    python3-setuptools \
    lsb-release \
    wget \
    build-essential \
    ninja-build \
    cmake \
    unzip \
    clang \
    gnupg \
    pkg-config \
    libgtk-3-dev \
    libnss3-dev \
    libgconf-2-4 \
    libasound2-dev \
    libpulse-dev \
    libxcomposite-dev \
    libxrandr-dev \
    libxi-dev \
    libxcursor-dev \
    libxtst-dev \
    libxdamage-dev \
    libpci-dev \
    libudev-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install depot_tools (required for fetching WebRTC source code)
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /opt/depot_tools
RUN ln -s /usr/bin/python3 /usr/bin/python
# Add depot_tools to PATH
ENV PATH="/opt/depot_tools:${PATH}"

# Clone the AlphaRTC repository
RUN git clone https://github.com/OpenNetLab/AlphaRTC.git /AlphaRTC

# Set the working directory to the AlphaRTC directory
WORKDIR /AlphaRTC

# Fetch WebRTC source code into the AlphaRTC directory
RUN cd /AlphaRTC && \
    gclient sync && \
    mv src/* . && \
    rm -rf src 

# Install GN (generate Ninja build files)
RUN cd /AlphaRTC && \
    gn gen out/Default

# Build WebRTC using Ninja
RUN cd /AlphaRTC && \
    ninja -C out/Default peerconnection_serverless

# Set the working directory to AlphaRTC for further development
WORKDIR /AlphaRTC

# By default, start a bash shell
CMD ["/bin/bash"]
```

## Makefile Design
```make
# 默认参数和变量
docker_image := challenge-env
docker_file_azure := dockers/Dockerfile.azure
docker_file_source := dockers/Dockerfile.source
build_from ?= azure  # 默认值为 azure

# 合法性检查
ifneq ($(build_from),azure)
ifneq ($(build_from),source)
$(error Unsupported build_from value: $(build_from))
endif
endif

# 主任务入口
all: $(build_from)

# 针对不同 build_from 的构建流程
azure:
	docker pull opennetlab.azurecr.io/alphartc
	docker image tag opennetlab.azurecr.io/alphartc alphartc
	docker build . --build-arg UID=$(shell id -u) --build-arg GUID=$(shell id -g) -f $(docker_file_azure) -t ${docker_image}

source:
	docker build . --build-arg UID=$(shell id -u) --build-arg GUID=$(shell id -g) -f $(docker_file_source) -t ${docker_image}

# 清理任务
clean:
	docker rmi -f ${docker_image}
```

- `make all build_from=source`

- `make clean`