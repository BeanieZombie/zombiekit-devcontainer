FROM ubuntu:24.04

# Install base dependencies and Docker
RUN apt-get update && \
    apt-get install -y \
    curl \
    sudo \
    git \
    build-essential \
    software-properties-common \
    docker.io && \
    rm -rf /var/lib/apt/lists/*

# Create runner user
RUN useradd -m runner
RUN echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Add runner user to docker group
RUN usermod -aG docker runner

USER runner
WORKDIR /home/runner

# Download and install GitHub Runner (Linux ARM64)
RUN curl -L https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-arm64-2.317.0.tar.gz \
    -o actions-runner-linux-arm64.tar.gz && \
    tar xzf actions-runner-linux-arm64.tar.gz && \
    rm actions-runner-linux-arm64.tar.gz

# Copy entrypoint script and set executable permission at copy time
COPY --chmod=0755 entrypoint.sh .

# Run the entrypoint script
ENTRYPOINT ["./entrypoint.sh"]