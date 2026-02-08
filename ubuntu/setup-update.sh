#!/usr/bin/env bash
set -euo pipefail

# Full system update (apt update + dist-upgrade + autoremove)
# Run as normal user (not root) — uses sudo where needed

echo "=== System Update ==="

# --- Source shared lib ---

_LIB="/tmp/.ubuntu-setup-lib.sh"
[[ -f "$_LIB" ]] || curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/lib.sh -o "$_LIB"
source "$_LIB"

# --- Update ---

echo "[1/3] Updating package lists..."
apt_update_if_stale

echo "[2/3] Upgrading packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y

echo "[3/3] Removing unused packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove -y

echo ""
echo "=== System Update Complete ==="
if [[ -f /var/run/reboot-required ]]; then
  echo "Reboot required."
else
  echo "No reboot needed."
fi
