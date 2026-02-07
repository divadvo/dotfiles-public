#!/usr/bin/env bash
set -euo pipefail

# Install Google Chrome on Ubuntu
# Must run as root (or with sudo)

echo "=== Google Chrome Setup ==="

echo "[1/2] Adding Google Chrome repository..."
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

echo "[2/2] Installing Google Chrome..."
DEBIAN_FRONTEND=noninteractive apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq google-chrome-stable > /dev/null

echo ""
echo "=== Google Chrome Setup Complete ==="
google-chrome --version
