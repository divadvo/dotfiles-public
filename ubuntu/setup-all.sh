#!/usr/bin/env bash
set -euo pipefail

# Interactive runner for manual setup scripts (not included in cloud-init)
# Run as normal user (not root)

BASE_URL="https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu"

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

# Scripts that require interactive input (no spinner)
INTERACTIVE_SCRIPTS=("setup-repos.sh" "setup-remote-desktop.sh")

CHOICES=$(gum choose --no-limit --height 9 --selected="Gum (CLI toolkit),Zsh + Oh My Zsh + Powerlevel10k,GitHub Repos (gh auth + clone),Google Chrome,Remote Desktop (xRDP + XFCE)" \
  "Gum (CLI toolkit)" \
  "Zsh + Oh My Zsh + Powerlevel10k" \
  "GitHub Repos (gh auth + clone)" \
  "Google Chrome" \
  "Remote Desktop (xRDP + XFCE)" \
  < /dev/tty)

if [[ -z "$CHOICES" ]]; then
  echo "Nothing selected."
  exit 0
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

  # Determine if script is interactive
  is_interactive=false
  for s in "${INTERACTIVE_SCRIPTS[@]}"; do
    if [[ "$s" == "$file" ]]; then
      is_interactive=true
      break
    fi
  done

  # Run the script
  if $is_interactive; then
    # Interactive scripts: run directly (need tty access)
    if $needs_sudo; then
      curl -fsSL "$BASE_URL/$file" | sudo bash
    else
      curl -fsSL "$BASE_URL/$file" | bash
    fi
  else
    # Non-interactive scripts: show output directly (spinners hide useful progress)
    if $needs_sudo; then
      curl -fsSL "$BASE_URL/$file" | sudo bash
    else
      curl -fsSL "$BASE_URL/$file" | bash
    fi
  fi

  echo ""
done <<< "$CHOICES"

gum style --border rounded --padding "0 2" --foreground 76 --bold "All done!"
