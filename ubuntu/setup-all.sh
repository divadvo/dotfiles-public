#!/usr/bin/env bash
set -euo pipefail

# Interactive runner for manual setup scripts (not included in cloud-init)
# Run as normal user (not root)
# Usage: bash setup-all.sh [--unattended]

BASE_URL="https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu"

UNATTENDED=false
[[ "${1:-}" == "--unattended" ]] && UNATTENDED=true

# --- Wait for cloud-init to finish (if still running) ---

curl -fsSL "$BASE_URL/monitor-cloud-init.sh" | bash
echo ""

# --- Ensure gum is installed ---

if ! command -v gum &> /dev/null; then
  echo "Installing gum (interactive CLI toolkit)..."
  curl -fsSL "$BASE_URL/setup-gum.sh" | bash
fi

# --- Header ---

echo ""
gum style --border rounded --padding "0 2" --foreground 212 --bold "Ubuntu Setup"
echo ""

# --- Multi-select menu ---

# Map display names to script files
declare -A SCRIPT_MAP
SCRIPT_MAP["Gum (CLI toolkit)"]="setup-gum.sh"
SCRIPT_MAP["Zsh + Oh My Zsh + Powerlevel10k"]="setup-zsh.sh"
SCRIPT_MAP["GitHub Repos (gh auth + clone)"]="setup-repos.sh"
SCRIPT_MAP["Google Chrome"]="setup-chrome.sh"
SCRIPT_MAP["Remote Desktop (xRDP + XFCE)"]="setup-remote-desktop.sh"
SCRIPT_MAP["System Update (dist-upgrade)"]="setup-update.sh"

if $UNATTENDED; then
  if [[ -n "${SETUP_CHOICES:-}" ]]; then
    CHOICES="$SETUP_CHOICES"
  else
    CHOICES="Gum (CLI toolkit)
Zsh + Oh My Zsh + Powerlevel10k
GitHub Repos (gh auth + clone)
Google Chrome
Remote Desktop (xRDP + XFCE)
System Update (dist-upgrade)"
  fi
else
  CHOICES=$(gum choose --no-limit --height 10 --selected="Gum (CLI toolkit),Zsh + Oh My Zsh + Powerlevel10k,GitHub Repos (gh auth + clone),Google Chrome,Remote Desktop (xRDP + XFCE),System Update (dist-upgrade)" \
    "Gum (CLI toolkit)" \
    "Zsh + Oh My Zsh + Powerlevel10k" \
    "GitHub Repos (gh auth + clone)" \
    "Google Chrome" \
    "Remote Desktop (xRDP + XFCE)" \
    "System Update (dist-upgrade)" \
    < /dev/tty)

  if [[ -z "$CHOICES" ]]; then
    echo "Nothing selected."
    exit 0
  fi
fi

echo ""

# --- Run selected scripts ---

while IFS= read -r choice; do
  file="${SCRIPT_MAP[$choice]}"

  gum style --foreground 99 --bold ">>> $choice"
  echo ""

  # Determine if script needs sudo
  needs_sudo=false
  case "$file" in
    setup-chrome.sh) needs_sudo=true ;;
  esac

  # Run the script
  if $needs_sudo; then
    curl -fsSL "$BASE_URL/$file" | sudo bash
  else
    curl -fsSL "$BASE_URL/$file" | bash
  fi

  echo ""
done <<< "$CHOICES"

gum style --border rounded --padding "0 2" --foreground 76 --bold "All done!"

# --- Reboot if needed ---

if [[ -f /var/run/reboot-required ]]; then
  echo ""
  if $UNATTENDED; then
    echo "Rebooting..."
    sudo reboot
  else
    if gum confirm "Reboot required. Reboot now?" < /dev/tty; then
      sudo reboot
    else
      echo "Run 'sudo reboot' when ready."
    fi
  fi
fi
