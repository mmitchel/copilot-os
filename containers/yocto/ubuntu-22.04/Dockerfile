FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash build-essential ca-certificates chrpath cpio curl debianutils diffstat \
    file gawk git iputils-ping lz4 locales python3 python3-git python3-jinja2 \
    python3-pexpect python3-pip socat sudo texinfo unzip wget xterm xz-utils zstd \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo -o /usr/local/bin/repo \
    && chmod 0755 /usr/local/bin/repo

RUN groupadd --gid 1000 yocto \
    && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash yocto

WORKDIR /workspace
RUN chown yocto:yocto /workspace

USER yocto
