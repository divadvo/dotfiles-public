#!/usr/bin/env bash
set -euo pipefail

# Install dev tools (uv, mise, node, bun, npm packages)
# Run as normal user (not root)

echo "=== Dev Tools Setup ==="

if [[ $EUID -eq 0 ]]; then
  echo "ERROR: Do not run as root. Run as your normal user."
  exit 1
fi

# --- uv ---

echo "[1/3] Installing uv + Python..."
curl -LsSf https://astral.sh/uv/install.sh | sh
~/.local/bin/uv python install 3.13 3.14
# ~/.local/bin/uv tool install build ruff
echo "uv installed."

# --- mise ---

echo "[2/3] Installing mise + runtimes..."
curl -fsSL https://mise.run | sh

# Add mise to bashrc if not already there
if ! grep -q 'mise activate bash' ~/.bashrc 2>/dev/null; then
  echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
fi

~/.local/bin/mise settings set disable_tools python
~/.local/bin/mise use -g node@24
~/.local/bin/mise use -g bun@1
echo "mise installed."

# --- npm tools ---

echo "[3/3] Installing npm tools..."
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
~/.local/bin/mise exec -- npm install -g yarn pnpm @anthropic-ai/claude-code
echo "npm tools installed."

echo ""
echo "=== Dev Tools Setup Complete ==="
