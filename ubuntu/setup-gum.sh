#!/usr/bin/env bash
set -euo pipefail

# Install gum (Charmbracelet) for glamorous shell scripts

echo "=== Gum Setup ==="

# --- Source shared lib ---

_LIB="/tmp/.ubuntu-setup-lib.sh"
[[ -f "$_LIB" ]] || curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/lib.sh -o "$_LIB"
source "$_LIB"

echo "[1/2] Adding Charm repository..."
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/charm.gpg 2>/dev/null
echo "deb [signed-by=/usr/share/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null

echo "[2/2] Installing gum..."
apt_update_if_stale
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq gum > /dev/null

echo ""
echo "=== Gum Setup Complete ==="
gum --version
