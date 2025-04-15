# Detect architecture from TARGETPLATFORM
ARG TARGETPLATFORM

# Base image for all platforms (using ubuntu:jammy)
FROM ubuntu:jammy AS base

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.24 based on architecture
RUN case "${TARGETPLATFORM}" in \
    "linux/amd64") \
        curl -fsSL https://go.dev/dl/go1.24.0.linux-amd64.tar.gz -o go1.24.0.tar.gz \
        && tar -C /usr/local -xzf go1.24.0.tar.gz \
        && rm go1.24.0.tar.gz \
        ;; \
    "linux/arm64") \
        curl -fsSL https://go.dev/dl/go1.24.0.linux-arm64.tar.gz -o go1.24.0.tar.gz \
        && tar -C /usr/local -xzf go1.24.0.tar.gz \
        && rm go1.24.0.tar.gz \
        ;; \
    "linux/riscv64") \
        curl -fsSL https://go.dev/dl/go1.24.0.linux-riscv64.tar.gz -o go1.24.0.tar.gz \
        && tar -C /usr/local -xzf go1.24.0.tar.gz \
        && rm go1.24.0.tar.gz \
        ;; \
    *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
    esac
ENV PATH=$PATH:/usr/local/go/bin

# Create non-root user 'vscode' with sudo privileges
RUN useradd -m -s /bin/bash vscode && echo "vscode:vscode" | chpasswd && adduser vscode sudo
RUN echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode

USER vscode
WORKDIR /home/vscode

# Copy and run setup script
COPY scripts/setup-tools.sh /home/vscode/setup-tools.sh
RUN chmod +x /home/vscode/setup-tools.sh && /home/vscode/setup-tools.sh