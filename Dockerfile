# Detect architecture from TARGETPLATFORM
ARG TARGETPLATFORM

# Base image for devcontainer (amd64, arm64)
FROM mcr.microsoft.com/vscode/devcontainers/go:1-1.22 AS devcontainer

# Base image for riscv64 (using riscv64/ubuntu:jammy)
FROM riscv64/ubuntu:jammy AS golang-riscv64
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    sudo \
    && rm -rf /var/lib/apt/lists/*
# Install Go 1.24 for riscv64
RUN curl -fsSL https://go.dev/dl/go1.24.0.linux-riscv64.tar.gz -o go1.24.0.linux-riscv64.tar.gz \
    && tar -C /usr/local -xzf go1.24.0.linux-riscv64.tar.gz \
    && rm go1.24.0.linux-riscv64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

# Use a multi-stage build to select the correct base image based on architecture
FROM golang-riscv64 AS base-riscv64
FROM devcontainer AS base-amd64
FROM devcontainer AS base-arm64

# Select the final base image based on TARGETPLATFORM
FROM base-${TARGETPLATFORM#linux/} AS final

# Install additional dependencies (ensure consistency across all platforms)
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user 'vscode' with sudo privileges
# Note: The devcontainer image already has this user, but riscv64/ubuntu:jammy does not
RUN useradd -m -s /bin/bash vscode && echo "vscode:vscode" | chpasswd && adduser vscode sudo || true
RUN echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode

USER vscode
WORKDIR /home/vscode

# Copy and run setup script
COPY scripts/setup-tools.sh /home/vscode/setup-tools.sh
RUN chmod +x /home/vscode/setup-tools.sh && /home/vscode/setup-tools.sh