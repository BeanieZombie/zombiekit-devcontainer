#!/bin/bash
     set -euo pipefail
     IFS=$'\n\t'

     echo "=== Installing Bun (latest version) ==="
     curl -fsSL https://bun.sh/install | bash || {
         echo "Error: Failed to download or execute Bun install script"
         exit 1
     }
     # Ensure Bun's bin is in PATH for future sessions and current shell
     if ! grep -q '$HOME/.bun/bin' "$HOME/.bashrc"; then
         echo 'export PATH=$PATH:$HOME/.bun/bin' >> "$HOME/.bashrc"
     fi
     export PATH=$PATH:"$HOME/.bun/bin"
     # Verify Bun installation
     if ! command -v bun >/dev/null; then
         echo "Error: Bun installation failed - bun command not found"
         exit 1
     fi
     echo "Bun version installed: $(bun --version)"

     echo "=== Installing Foundry (v0.2.0) ==="
     curl -L https://foundry.paradigm.xyz | bash
     "$HOME/.foundry/bin/foundryup" --version v0.2.0
     if ! grep -q '$HOME/.foundry/bin' "$HOME/.bashrc"; then
         echo 'export PATH=$PATH:$HOME/.foundry/bin' >> "$HOME/.bashrc"
     fi
     export PATH=$PATH:"$HOME/.foundry/bin"

     echo "=== Cloning and building Sonic (v2.0.1) ==="
     SONIC_DIR="$HOME/sonic"
     mkdir -p "$SONIC_DIR"
     cd "$SONIC_DIR"
     # Only clone if the repository isn't already cloned
     if [ ! -d ".git" ]; then
         git clone https://github.com/0xsoniclabs/Sonic.git .
     fi
     git fetch --tags
     git checkout -B v2.0.1 tags/v2.0.1
     make all

     echo "=== Copying binaries to \$HOME/bin ==="
     mkdir -p "$HOME/bin"
     # Use quotes and check if files exist before copying
     if [ -f "build/bin/sonicd" ]; then
         cp "build/bin/sonicd" "$HOME/bin/"
     else
         echo "Error: build/bin/sonicd not found." && exit 1
     fi

     if [ -f "build/bin/sonictool" ]; then
         cp "build/bin/sonictool" "$HOME/bin/"
     else
         echo "Error: build/bin/sonictool not found." && exit 1
     fi

     if ! grep -q '$HOME/bin' "$HOME/.bashrc"; then
         echo 'export PATH=$PATH:$HOME/bin' >> "$HOME/.bashrc"
     fi
     export PATH=$PATH:"$HOME/bin"

     echo "=== Installation complete ==="