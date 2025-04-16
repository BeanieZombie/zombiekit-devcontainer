# Build stage for Sonic
FROM golang:1.24 AS builder

ARG VERSION=v2.0.1

# Install build dependencies for Sonic
RUN apt-get update && apt-get install -y \
    git \
    musl-dev \
    make \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone Sonic with shallow clone for efficiency
RUN cd /go && git clone --depth 1 --branch ${VERSION} https://github.com/0xsoniclabs/sonic.git

WORKDIR /go/sonic

# Ensure dependencies are downloaded
RUN go mod download || { echo "Failed to download Go dependencies."; exit 1; }

# Debug: Print the Makefile to understand build targets
RUN cat /go/sonic/Makefile

# Debug: List the cmd directory to confirm source files
RUN ls -l /go/sonic/cmd/

# Build Sonic with verbose output, log any errors
RUN make all V=1 || { echo "Build failed. Check verbose output above for details."; exit 1; }

# Debug: List the entire build directory to check for binaries
RUN ls -lR /go/sonic/build/

# Validate that the binaries exist before proceeding
RUN if [ ! -f /go/sonic/build/bin/sonicd ] || [ ! -f /go/sonic/build/bin/sonictool ]; then \
        echo "Required binaries not found in /go/sonic/build/bin/"; \
        exit 1; \
    fi

# Debug: List the bin directory contents to confirm presence
RUN ls -l /go/sonic/build/bin/

# Runtime stage
# Detect architecture from TARGETPLATFORM, with a default value
ARG TARGETPLATFORM=linux/amd64
ARG TARGETARCH
ARG TARGETVARIANT

# Base image for all platforms (using ubuntu:jammy)
FROM ubuntu:jammy AS base

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    sudo \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Debug: Print TARGETPLATFORM, TARGETARCH, and TARGETVARIANT values
RUN echo "Building for TARGETPLATFORM: ${TARGETPLATFORM}, TARGETARCH: ${TARGETARCH}, TARGETVARIANT: ${TARGETVARIANT}"

# Install Go 1.24 for runtime use
RUN case "${TARGETPLATFORM:-linux/amd64}" in \
    linux/amd64*) \
        echo "Normalized platform: linux/amd64" \
        && curl -sSL --retry 3 --retry-delay 5 https://go.dev/dl/go1.24.0.linux-amd64.tar.gz -o go1.24.0.tar.gz || { echo "Failed to download Go for amd64 after retries"; exit 1; } \
        && tar -C /usr/local -xzf go1.24.0.tar.gz || { echo "Failed to extract Go tarball for amd64"; exit 1; } \
        && rm go1.24.0.tar.gz \
        ;; \
    linux/arm64*) \
        echo "Normalized platform: linux/arm64" \
        && curl -sSL --retry 3 --retry-delay 5 https://go.dev/dl/go1.24.0.linux-arm64.tar.gz -o go1.24.0.tar.gz || { echo "Failed to download Go for arm64 after retries"; exit 1; } \
        && tar -C /usr/local -xzf go1.24.0.tar.gz || { echo "Failed to extract Go tarball for arm64"; exit 1; } \
        && rm go1.24.0.tar.gz \
        ;; \
    *) \
        echo "Unsupported platform: ${TARGETPLATFORM:-linux/amd64}" && exit 1 \
        ;; \
    esac
ENV PATH=$PATH:/usr/local/go/bin

# Copy Sonic binaries from the builder stage
COPY --from=builder /go/sonic/build/bin/sonicd /usr/local/bin/
COPY --from=builder /go/sonic/build/bin/sonictool /usr/local/bin/

# Create non-root user 'vscode' with sudo privileges
RUN useradd -m -s /bin/bash vscode && echo "vscode:vscode" | chpasswd && adduser vscode sudo
RUN echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode

# Copy and set permissions for setup script before switching user
COPY scripts/setup-tools.sh /home/vscode/setup-tools.sh
RUN chown vscode:vscode /home/vscode/setup-tools.sh && chmod +x /home/vscode/setup-tools.sh

USER vscode
WORKDIR /home/vscode

# Run setup script (for Bun and Foundry installation)
RUN /home/vscode/setup-tools.sh