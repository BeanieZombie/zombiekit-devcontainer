FROM mcr.microsoft.com/vscode/devcontainers/go:1-1.22

     # Install additional dependencies
     RUN apt-get update && apt-get install -y \
         curl \
         git \
         build-essential \
         sudo \
         && rm -rf /var/lib/apt/lists/*

     # Ensure non-root user 'vscode' exists (already in base image, but confirming)
     RUN useradd -ms /bin/bash vscode || true && echo "vscode ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/vscode

     USER vscode
     WORKDIR /home/vscode

     # Copy and run setup script
     COPY scripts/setup-tools.sh /home/vscode/setup-tools.sh
     RUN chmod +x /home/vscode/setup-tools.sh && /home/vscode/setup-tools.sh