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
     if [ ! -d ".git" ]; then
         git clone https://github.com/sonic-labs/sonic-core.git .
     fi
     git fetch --tags
     if ! git rev-parse "tags/v2.0.1" >/dev/null 2>&1; then
         echo "Error: Tag v2.0.1 not found in sonic-core repository"
         exit 1
     fi
     git checkout -B v2.0.1 tags/v2.0.1

     echo "Running make all..."
     make all || {
         echo "Error: Sonic build failed with make all"
         exit 1
     }
     ls -R build || {
         echo "Error: Failed to list build directory after make all"
         exit 1
     }

     echo "=== Copying binaries to \$HOME/bin ==="
     mkdir -p "$HOME/bin"
     if [ -f "build/bin/sonicd" ]; then
         cp "build/bin/sonicd" "$HOME/bin/"
     else
         echo "Error: build/bin/sonicd not found after make all"
         exit 1
     fi

     if [ -f "build/bin/sonictool" ]; then
         cp "build/bin/sonictool" "$HOME/bin/"
     else
         echo "Error: build/bin/sonictool not found after make all"
         exit 1
     fi

     if ! grep -q '$HOME/bin' "$HOME/.bashrc"; then
         echo 'export PATH=$PATH:$HOME/bin' >> "$HOME/.bashrc"
     fi
     export PATH=$PATH:"$HOME/bin"

     echo "=== Installation complete ==="