#!/usr/bin/env bash
set -euo pipefail

# Install and configure Tailscale (optionally with UFW firewall)
# Usage: setup-tailscale.sh --auth-key KEY [--ssh] [--exit-node] [--tags TAGS] [--ufw]
# Must run as root

echo "=== Tailscale Setup ==="

# --- Source shared lib ---

_LIB="/tmp/.ubuntu-setup-lib.sh"
[[ -f "$_LIB" ]] || curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/lib.sh -o "$_LIB"
source "$_LIB"

# --- Parse arguments ---

AUTH_KEY=""
ENABLE_SSH=false
ENABLE_EXIT_NODE=false
ENABLE_UFW=false
TAGS=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --auth-key) AUTH_KEY="$2"; shift 2 ;;
    --auth-key=*) AUTH_KEY="${1#*=}"; shift ;;
    --ssh) ENABLE_SSH=true; shift ;;
    --exit-node) ENABLE_EXIT_NODE=true; shift ;;
    --ufw) ENABLE_UFW=true; shift ;;
    --tags) TAGS="$2"; shift 2 ;;
    --tags=*) TAGS="${1#*=}"; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$AUTH_KEY" ]]; then
  echo "ERROR: --auth-key is required"
  exit 1
fi

# --- UFW firewall (optional) ---

if $ENABLE_UFW; then
  echo "[1/4] Configuring UFW firewall..."
  apt_update_if_stale
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ufw > /dev/null
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow 41641/udp comment 'Tailscale'
  ufw allow in on tailscale0 comment 'Allow all Tailscale traffic'
  ufw --force enable
  echo "UFW configured (deny all except Tailscale)."
else
  echo "[1/4] Skipping UFW (not requested)."
fi

# --- Install Tailscale ---

echo "[2/4] Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh
echo "Tailscale installed."

# --- Enable IP forwarding ---

echo "[3/4] Enabling IP forwarding..."
echo 'net.ipv4.ip_forward = 1' | tee /etc/sysctl.d/99-tailscale.conf > /dev/null
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf > /dev/null
sysctl -p /etc/sysctl.d/99-tailscale.conf > /dev/null
echo "IP forwarding enabled."

# --- Start Tailscale ---

echo "[4/4] Starting Tailscale..."
UP_ARGS="--authkey=${AUTH_KEY}"
[[ -n "$TAGS" ]] && UP_ARGS+=" --advertise-tags=${TAGS}"
$ENABLE_SSH && UP_ARGS+=" --ssh" || true
$ENABLE_EXIT_NODE && UP_ARGS+=" --advertise-exit-node" || true
echo "Running: tailscale up $UP_ARGS"
tailscale up $UP_ARGS
$ENABLE_SSH && echo "Tailscale SSH enabled." || true
$ENABLE_EXIT_NODE && echo "Tailscale exit node enabled." || true

echo ""
echo "=== Tailscale Setup Complete ==="
tailscale status
