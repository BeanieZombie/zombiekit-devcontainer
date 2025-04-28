#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "=== Installing Bun (latest version) ==="
curl -fsSL https://bun.sh/install | bash || {
    echo "Error: Failed to download or execute Bun install script"
    exit 1
}

# Ensure Bun's bin is in PATH for future sessions and current shell
if ! grep -q "\$HOME/.bun/bin" "$HOME/.bashrc"; then
    echo 'export PATH=$PATH:$HOME/.bun/bin' >> "$HOME/.bashrc"
fi
export PATH=$PATH:"$HOME/.bun/bin"

# Verify Bun installation
if ! command -v bun >/dev/null; then
    echo "Error: Bun installation failed - bun command not found"
    exit 1
fi
echo "✅ Bun version installed: $(bun --version)"

echo "=== Installing Foundry (latest version) ==="
curl -L https://foundry.paradigm.xyz | bash
"$HOME/.foundry/bin/foundryup"

# Ensure Foundry's bin is in PATH for future sessions and current shell
if ! grep -q "\$HOME/.foundry/bin" "$HOME/.bashrc"; then
    echo 'export PATH=$PATH:$HOME/.foundry/bin' >> "$HOME/.bashrc"
fi
export PATH=$PATH:"$HOME/.foundry/bin"

# Also create a global profile so new terminals pick up Foundry
if [ ! -f /etc/profile.d/foundry.sh ]; then
    echo 'export PATH=$PATH:$HOME/.foundry/bin' | sudo tee /etc/profile.d/foundry.sh > /dev/null
fi

echo 'export PATH=$PATH:$HOME/.foundry/bin' | sudo tee /etc/profile.d/foundry.sh > /dev/null

# Verify Foundry installation
if ! command -v forge >/dev/null; then
    echo "Error: Foundry installation failed - forge command not found"
    exit 1
fi
echo "✅ Forge version installed: $(forge --version)"

echo "=== ✅ Installation complete: Bun and Foundry are ready ==="
