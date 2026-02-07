#!/usr/bin/env bash
set -euo pipefail

# Monitor cloud-init progress in real-time
# Run after SSHing into a freshly provisioned server

LOG="/var/log/cloud-init-output.log"

# Use gum if available, plain echo as fallback
styled() {
  if command -v gum &>/dev/null; then
    gum style --border rounded --padding "0 2" --foreground "$1" --bold "$2"
  else
    echo "=== $2 ==="
  fi
}

show_summary() {
  echo ""
  styled 76 "Cloud-init complete!"
  echo ""

  # Server info
  UPTIME=$(awk '{printf "%dm %ds", $1/60, $1%60}' /proc/uptime)
  echo "Server:"
  echo "  Hostname:  $(hostname -f 2>/dev/null || hostname)"
  echo "  OS:        $(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || echo "unknown")"
  echo "  Public IP: $(curl -4s --max-time 3 https://ifconfig.me 2>/dev/null || echo "unavailable")"
  echo "  Created:   $(stat -c '%y' /etc/machine-id 2>/dev/null | cut -d. -f1 || echo "unknown")"
  echo "  Booted:    $(uptime -s 2>/dev/null || echo "unknown")"
  echo "  Uptime:    $UPTIME"
  echo ""

  # Status
  echo "Status:"
  sudo cloud-init status --long 2>/dev/null || true
  echo ""

  # Quick checks
  echo "Installed:"
  command -v tailscale &>/dev/null && echo "  tailscale $(tailscale version 2>/dev/null | head -1)" || echo "  tailscale: not found"
  command -v docker &>/dev/null && echo "  $(docker --version 2>/dev/null)" || echo "  docker: not found"
  command -v node &>/dev/null && echo "  node $(node --version 2>/dev/null)" || echo "  node: not found"
  command -v uv &>/dev/null && echo "  uv $(uv --version 2>/dev/null)" || echo "  uv: not found"
  command -v gh &>/dev/null && echo "  $(gh --version 2>/dev/null | head -1)" || echo "  gh: not found"
  echo ""

  # System health
  echo "Health:"
  echo "  Disk:    $(df -h / 2>/dev/null | awk 'NR==2{print $3 "/" $2 " (" $5 " used)"}')"
  echo "  Memory:  $(free -h 2>/dev/null | awk '/Mem:/{print $3 "/" $2 " used"}')"
  echo "  Load:    $(awk '{print $1 " " $2 " " $3}' /proc/loadavg 2>/dev/null || echo "unknown")"
  echo ""

  # Networking
  echo "Network:"
  if command -v tailscale &>/dev/null && tailscale status &>/dev/null; then
    echo "  Tailscale IP: $(tailscale ip -4 2>/dev/null || echo "unavailable")"
    echo "  Tailscale:    $(tailscale status --peers=false 2>/dev/null | head -1 || echo "unknown")"
  else
    echo "  Tailscale: not running"
  fi
  if command -v ufw &>/dev/null; then
    echo "  Firewall:  $(sudo ufw status 2>/dev/null | head -1)"
  fi
  echo ""

  # Pending updates
  echo "Updates:"
  UPGRADABLE=$(apt list --upgradable 2>/dev/null | grep -c upgradable || true)
  UPGRADABLE="${UPGRADABLE:-0}"
  if [[ "$UPGRADABLE" -gt 0 ]]; then
    echo "  $UPGRADABLE package(s) upgradable"
  else
    echo "  System is up to date"
  fi
  if [[ -f /var/run/reboot-required ]]; then
    echo "  REBOOT REQUIRED"
  else
    echo "  No reboot needed"
  fi
  echo ""

  # Errors
  ERRORS=$(sudo grep -ciE "error|fatal|traceback" "$LOG" 2>/dev/null || true)
  ERRORS="${ERRORS:-0}"
  if [[ "$ERRORS" -gt 0 ]]; then
    echo "WARNING: Found $ERRORS lines with errors. Review with:"
    echo "  sudo grep -iE 'error|fatal|traceback' $LOG"
  else
    echo "No errors detected in cloud-init log."
  fi
}

# --- Check if already done ---

STATUS=$(sudo cloud-init status 2>/dev/null | awk '{print $NF}')
if [[ "$STATUS" == "done" || "$STATUS" == "error" ]]; then
  echo "Cloud-init already finished (status: $STATUS)."
  show_summary
  exit 0
fi

# --- Monitor ---

styled 212 "Monitoring cloud-init"
echo ""
echo "Status: $STATUS"
echo "Tailing $LOG (Ctrl+C to stop watching)..."
echo ""

# Tail log in background
sudo tail -f "$LOG" &
TAIL_PID=$!

# Clean up tail on exit
trap 'kill $TAIL_PID 2>/dev/null; wait $TAIL_PID 2>/dev/null' EXIT

# Wait for cloud-init to finish
sudo cloud-init status --wait > /dev/null 2>&1

# Stop tail
kill $TAIL_PID 2>/dev/null
wait $TAIL_PID 2>/dev/null
trap - EXIT

show_summary
