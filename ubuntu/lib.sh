#!/usr/bin/env bash
# Shared functions for ubuntu setup scripts
# Sourced via: _LIB="/tmp/.ubuntu-setup-lib.sh"
#   [[ -f "$_LIB" ]] || curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/lib.sh -o "$_LIB"
#   source "$_LIB"

# Run apt-get update only if the cache is older than 5 minutes
# Auto-detects whether sudo is needed
apt_update_if_stale() {
  local cache="/var/cache/apt/pkgcache.bin"
  local sudo_cmd=""
  [[ $EUID -ne 0 ]] && sudo_cmd="sudo"
  if [[ ! -f "$cache" ]]; then
    echo "[apt] No cache found, running apt-get update..."
    $sudo_cmd env DEBIAN_FRONTEND=noninteractive apt-get update -qq
  elif [[ $(($(date +%s) - $(stat -c %Y "$cache"))) -gt 300 ]]; then
    echo "[apt] Cache is stale, running apt-get update..."
    $sudo_cmd env DEBIAN_FRONTEND=noninteractive apt-get update -qq
  elif [[ $(find /etc/apt/sources.list.d -newer "$cache" 2>/dev/null | head -1) ]]; then
    echo "[apt] New repo detected, running apt-get update..."
    $sudo_cmd env DEBIAN_FRONTEND=noninteractive apt-get update -qq
  else
    echo "[apt] Cache is fresh, skipping apt-get update."
  fi
}
