#!/usr/bin/env bash
set -euo pipefail

# Interactive runner for manual setup scripts (not included in cloud-init)
# Run as normal user (not root)

BASE_URL="https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu"

SCRIPTS=(
  "setup-zsh.sh|Zsh + Oh My Zsh + Powerlevel10k"
  "setup-repos.sh|GitHub Repos (gh auth + clone)"
  "setup-chrome.sh|Google Chrome"
  "setup-remote-desktop.sh|Remote Desktop (xRDP + XFCE)"
)

echo "=== Ubuntu Setup ==="
echo ""
echo "Available scripts:"
for i in "${!SCRIPTS[@]}"; do
  desc="${SCRIPTS[$i]#*|}"
  echo "  $((i + 1)). $desc"
done
echo ""
echo "Enter numbers to run (e.g. '1 2 3'), 'all', or 'q' to quit:"
read -r choice < /dev/tty

if [[ "$choice" == "q" ]]; then
  echo "Cancelled."
  exit 0
fi

# Build list of selected indices
selected=()
if [[ "$choice" == "all" ]]; then
  for i in "${!SCRIPTS[@]}"; do
    selected+=("$i")
  done
else
  for num in $choice; do
    idx=$((num - 1))
    if [[ $idx -ge 0 && $idx -lt ${#SCRIPTS[@]} ]]; then
      selected+=("$idx")
    else
      echo "WARNING: Invalid selection '$num', skipping."
    fi
  done
fi

if [[ ${#selected[@]} -eq 0 ]]; then
  echo "Nothing selected."
  exit 0
fi

echo ""

# Run selected scripts
for idx in "${selected[@]}"; do
  entry="${SCRIPTS[$idx]}"
  file="${entry%%|*}"
  desc="${entry#*|}"

  echo "━━━ Running: $desc ━━━"
  echo ""

  # Scripts that need sudo run the whole script elevated
  # Scripts that run as user are piped directly
  case "$file" in
    setup-chrome.sh)
      curl -fsSL "$BASE_URL/$file" | sudo bash
      ;;
    *)
      curl -fsSL "$BASE_URL/$file" | bash
      ;;
  esac

  echo ""
done

echo "=== All done! ==="
