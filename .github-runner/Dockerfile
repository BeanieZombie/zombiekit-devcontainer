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
    && rm -rf /var/lib/apt/lists/*

# Create docker group + runner user
RUN groupadd docker && \
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