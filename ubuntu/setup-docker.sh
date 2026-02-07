#!/usr/bin/env bash
set -euo pipefail

# Install Docker and add users to docker group
# Usage: setup-docker.sh <username> [username...]
# Must run as root

echo "=== Docker Setup ==="

if [[ $# -eq 0 ]]; then
  echo "ERROR: Provide at least one username"
  echo "Usage: setup-docker.sh <username> [username...]"
  exit 1
fi

# --- Install Docker ---

echo "[1/2] Installing Docker..."
curl -fsSL https://get.docker.com | sh
echo "Docker installed."

# --- Add users to docker group ---

echo "[2/2] Adding users to docker group..."
for user in "$@"; do
  usermod -aG docker "$user"
  echo "  Added $user to docker group."
done

echo ""
echo "=== Docker Setup Complete ==="
docker --version
