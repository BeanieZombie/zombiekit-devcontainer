#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

MODE="${1:-user-setup}"

if [[ "$MODE" == "--root-setup" ]]; then
    echo "=== [ROOT] Setting up system-wide binaries ==="

    # Move Bun to /usr/local/bin if it exists
    if [[ -f "$HOME/.bun/bin/bun" ]]; then
        echo "Moving Bun binary to /usr/local/bin"
        mv "$HOME/.bun/bin/bun" /usr/local/bin/
        rm -rf "$HOME/.bun"
    fi

    # Move Foundry binaries to /usr/local/bin if they exist
    if [[ -d "$HOME/.foundry/bin" ]]; then
        echo "Moving Foundry binaries to /usr/local/bin"
        cp "$HOME/.foundry/bin/"* /usr/local/bin/
        rm -rf "$HOME/.foundry"
    fi

    echo "✅ System-wide binaries installed."
    exit 0
fi

if [[ "$MODE" == "--user-setup" ]]; then
    echo "=== Installing Bun (latest version) ==="
    curl -fsSL https://bun.sh/install | bash
    export PATH=$PATH:"$HOME/.bun/bin"

    echo "✅ Bun installed: $(bun --version)"

    echo "=== Installing Foundry (latest version) ==="
    curl -L https://foundry.paradigm.xyz | bash
    "$HOME/.foundry/bin/foundryup"

    export PATH=$PATH:"$HOME/.foundry/bin"

    echo "✅ Forge installed: $(forge --version)"

    echo "=== User Setup Complete ==="
    exit 0
fi

echo "❌ Unknown setup mode: $MODE"
exit 1
