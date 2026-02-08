#!/usr/bin/env bash
set -euo pipefail

# Install zsh, oh-my-zsh, powerlevel10k, and plugins on Ubuntu
# Run as normal user (not root)

echo "=== Zsh Setup ==="

if [[ $EUID -eq 0 ]]; then
  echo "ERROR: Do not run as root. Run as your normal user."
  exit 1
fi

# --- Source shared lib ---

_LIB="/tmp/.ubuntu-setup-lib.sh"
[[ -f "$_LIB" ]] || curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/lib.sh -o "$_LIB"
source "$_LIB"

# --- Install zsh, fzf, zoxide ---

echo "[1/5] Installing zsh, fzf, zoxide..."
apt_update_if_stale
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq zsh fzf zoxide > /dev/null
echo "Packages installed."

# --- Oh My Zsh ---

echo "[2/5] Installing Oh My Zsh..."
if [[ -d ~/.oh-my-zsh ]]; then
  echo "Already installed, skipping."
else
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  echo "Oh My Zsh installed."
fi

# --- Powerlevel10k + plugins (parallel) ---

echo "[3/5] Installing Powerlevel10k theme + plugins..."

[[ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]] || \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k &
[[ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]] || \
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions &
[[ -d ~/.oh-my-zsh/custom/plugins/zsh-you-should-use ]] || \
  git clone --depth=1 https://github.com/MichaelAquilina/zsh-you-should-use.git ~/.oh-my-zsh/custom/plugins/zsh-you-should-use &
wait
echo "Powerlevel10k + plugins installed."

# --- Write .zshrc ---

echo "[4/5] Downloading ~/.zshrc and ~/.p10k.zsh..."
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/dotfiles/zshrc -o ~/.zshrc
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/dotfiles/p10k.zsh -o ~/.p10k.zsh
echo ".zshrc and .p10k.zsh written."

# --- Change default shell ---

echo "[5/5] Setting zsh as default shell..."
if [[ "$(basename "$SHELL")" == "zsh" ]]; then
  echo "Already using zsh."
else
  sudo chsh -s "$(which zsh)" "$USER"
  echo "Default shell changed to zsh."
fi

echo ""
echo "=== Zsh Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Run 'exec zsh' or re-login to start zsh"
echo "  2. Powerlevel10k is pre-configured (re-run with: p10k configure)"
