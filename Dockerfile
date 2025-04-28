# Base image
FROM ubuntu:jammy AS base

# Install additional dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    unzip \
    apt-utils \
    net-tools \
    iputils-ping \
    docker.io \
    && rm -rf /var/lib/apt/lists/*


# Debug: Print TARGETPLATFORM, TARGETARCH, and TARGETVARIANT
ARG TARGETPLATFORM=linux/amd64
ARG TARGETARCH
ARG TARGETVARIANT
RUN echo "Building for TARGETPLATFORM: ${TARGETPLATFORM}, TARGETARCH: ${TARGETARCH}, TARGETVARIANT: ${TARGETVARIANT}"

# Install Go 1.24
RUN case "${TARGETPLATFORM:-linux/amd64}" in \
    linux/amd64*) \
        curl -sSL --retry 3 --retry-delay 5 https://go.dev/dl/go1.24.0.linux-amd64.tar.gz -o go1.24.0.tar.gz \
        && tar -C /usr/local -xzf go1.24.0.tar.gz \
        && rm go1.24.0.tar.gz \
        ;; \
    linux/arm64*) \
        curl -sSL --retry 3 --retry-delay 5 https://go.dev/dl/go1.24.0.linux-arm64.tar.gz -o go1.24.0.tar.gz \
        && tar -C /usr/local -xzf go1.24.0.tar.gz \
        && rm go1.24.0.tar.gz \
        ;; \
    *) \
        echo "Unsupported platform: ${TARGETPLATFORM:-linux/amd64}" && exit 1 \
        ;; \
    esac
ENV PATH=$PATH:/usr/local/go/bin

# Create non-root user vscode
RUN useradd -m -s /bin/bash vscode

# Copy and set permissions for setup script
COPY scripts/setup-tools.sh /home/vscode/setup-tools.sh
RUN chown vscode:vscode /home/vscode/setup-tools.sh && chmod +x /home/vscode/setup-tools.sh

USER vscode
WORKDIR /home/vscode

# Run setup script
RUN /home/vscode/setup-tools.sh

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 CMD ["bash", "-c", "exit 0"]
