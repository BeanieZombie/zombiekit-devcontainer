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

# Sonic binaries (sonicd, sonictool) are already built and copied to /usr/local/bin by the Dockerfile
# Verify Sonic binaries are available
if ! command -v sonicd >/dev/null; then
    echo "Error: sonicd command not found"
    exit 1
fi
if ! command -v sonictool >/dev/null; then
    echo "Error: sonictool command not found"
    exit 1
fi

echo "=== Installation complete ==="