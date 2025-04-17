FROM ubuntu:24.04

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    sudo \
    git \
    build-essential \
    software-properties-common \
    docker.io \
    qemu-user-static \
    ca-certificates \
    gnupg \
    lsb-release \
    inetutils-ping \
    dnsutils && \
    rm -rf /var/lib/apt/lists/*

# Install Docker Buildx plugin (ARM64)
RUN mkdir -p /usr/libexec/docker/cli-plugins && \
    curl -sSL https://github.com/docker/buildx/releases/download/v0.12.0/buildx-v0.12.0.linux-arm64 -o /usr/libexec/docker/cli-plugins/docker-buildx && \
    chmod +x /usr/libexec/docker/cli-plugins/docker-buildx

# Ensure docker group exists and create runner user with necessary permissions
RUN if ! getent group docker >/dev/null; then groupadd docker; fi && \
    useradd -m -s /bin/bash runner && \
    usermod -aG sudo runner && \
    usermod -aG docker runner && \
    echo "runner ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/runner

USER runner
WORKDIR /home/runner

# Download GitHub Actions runner
RUN curl -L -o actions-runner.tar.gz https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-arm64-2.317.0.tar.gz && \
    tar xzf actions-runner.tar.gz && \
    rm actions-runner.tar.gz

# Add entrypoint script
COPY --chmod=0755 entrypoint.sh .

ENTRYPOINT ["./entrypoint.sh"]
