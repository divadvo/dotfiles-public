#!/usr/bin/env bash
set -euo pipefail

# Install system packages on Ubuntu
# Must run as root

echo "=== System Packages Setup ==="

# --- Source shared lib ---

_LIB="/tmp/.ubuntu-setup-lib.sh"
[[ -f "$_LIB" ]] || curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/lib.sh -o "$_LIB"
source "$_LIB"

# --- GitHub CLI repo ---

echo "[1/2] Adding GitHub CLI repository..."
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
echo "GitHub CLI repo added."

# --- Install packages ---

echo "[2/2] Installing packages..."
apt_update_if_stale
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
  git git-lfs neovim build-essential wget curl \
  fd-find ripgrep rsync tree htop bat lsd \
  libssl-dev libreadline-dev libyaml-dev libz-dev libffi-dev \
  btm just tealdeer gh \
  > /dev/null
echo "Packages installed."

# --- Disable Ubuntu Pro/ESM MOTD messages ---

pro config set apt_news=false 2>/dev/null || true
chmod -x /etc/update-motd.d/88-esm-announce 2>/dev/null || true
chmod -x /etc/update-motd.d/91-contract-ua-esm-status 2>/dev/null || true

echo ""
echo "=== System Packages Setup Complete ==="
