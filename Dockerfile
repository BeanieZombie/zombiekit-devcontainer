# Detect architecture from TARGETPLATFORM
ARG TARGETPLATFORM

# Default to golang:1.24 for unsupported platforms (e.g., riscv64)
# Otherwise, use the devcontainer image for amd64 and arm64
FROM mcr.microsoft.com/vscode/devcontainers/go:1-1.22 AS devcontainer
FROM golang:1.24 AS golang

# Use a multi-stage build to select the correct base image based on architecture
FROM golang AS base-riscv64
FROM devcontainer AS base-amd64
FROM devcontainer AS base-arm64

# Select the final base image based on TARGETPLATFORM
FROM base-${TARGETPLATFORM#linux/} AS final

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user 'vscode' with sudo privileges
# Note: The devcontainer image already has this user, but golang image does not
RUN useradd -m -s /bin/bash vscode && echo "vscode:vscode" | chpasswd && adduser vscode sudo || true
RUN echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode

USER vscode
WORKDIR /home/vscode

# Copy and run setup script
COPY scripts/setup-tools.sh /home/vscode/setup-tools.sh
RUN chmod +x /home/vscode/setup-tools.sh && /home/vscode/setup-tools.sh