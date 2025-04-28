# Base image
FROM ubuntu:jammy AS base

# Install additional dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    build-essential \
    unzip \
    apt-utils \
    net-tools \
    iputils-ping \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Debug: Print TARGETPLATFORM, TARGETARCH, and TARGETVARIANT
ARG TARGETPLATFORM=linux/amd64
ARG TARGETARCH
ARG TARGETVARIANT
RUN echo "Building for TARGETPLATFORM: ${TARGETPLATFORM}, TARGETARCH: ${TARGETARCH}, TARGETVARIANT: ${TARGETVARIANT}"

# Install Go 1.24 based on platform
RUN bash -c "set -euo pipefail && \
    case \"${TARGETPLATFORM:-linux/amd64}\" in \
      linux/amd64*) \
        curl -sSL --retry 5 --retry-delay 5 https://go.dev/dl/go1.24.0.linux-amd64.tar.gz -o go1.24.0.tar.gz && \
        tar -C /usr/local -xzf go1.24.0.tar.gz && \
        rm go1.24.0.tar.gz ;; \
      linux/arm64*) \
        curl -sSL --retry 5 --retry-delay 5 https://go.dev/dl/go1.24.0.linux-arm64.tar.gz -o go1.24.0.tar.gz && \
        tar -C /usr/local -xzf go1.24.0.tar.gz && \
        rm go1.24.0.tar.gz ;; \
      *) \
        echo \"Unsupported platform: \${TARGETPLATFORM:-linux/amd64}\" && exit 1 ;; \
    esac"

ENV PATH=$PATH:/usr/local/go/bin

# Create non-root user 'vscode'
RUN useradd -m -s /bin/bash vscode

# Copy setup script
COPY scripts/setup-tools.sh /home/vscode/setup-tools.sh
RUN chmod +x /home/vscode/setup-tools.sh

# Switch to user context and run user-level setup
USER vscode
WORKDIR /home/vscode
RUN /home/vscode/setup-tools.sh --user-setup

# Switch back to root and run root-level setup
USER root
RUN /home/vscode/setup-tools.sh --root-setup

# Cleanup leftover script
RUN rm -f /home/vscode/setup-tools.sh

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 CMD ["bash", "-c", "exit 0"]
