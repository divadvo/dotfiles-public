#!/usr/bin/env bash
set -euo pipefail

# Install zsh, oh-my-zsh, powerlevel10k, and plugins on Ubuntu
# Run as normal user (not root)

echo "=== Zsh Setup ==="

if [[ $EUID -eq 0 ]]; then
  echo "ERROR: Do not run as root. Run as your normal user."
  exit 1
fi

# --- Install zsh, fzf, zoxide ---

echo "[1/6] Installing zsh, fzf, zoxide..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq zsh fzf zoxide > /dev/null
echo "Packages installed."

# --- Oh My Zsh ---

echo "[2/6] Installing Oh My Zsh..."
if [[ -d ~/.oh-my-zsh ]]; then
  echo "Already installed, skipping."
else
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  echo "Oh My Zsh installed."
fi

# --- Powerlevel10k ---

echo "[3/6] Installing Powerlevel10k theme..."
if [[ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]]; then
  echo "Already installed, skipping."
else
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
  echo "Powerlevel10k installed."
fi

# --- Custom plugins ---

echo "[4/6] Installing custom plugins..."

if [[ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
  echo "zsh-autosuggestions already installed."
else
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  echo "zsh-autosuggestions installed."
fi

if [[ -d ~/.oh-my-zsh/custom/plugins/zsh-you-should-use ]]; then
  echo "zsh-you-should-use already installed."
else
  git clone --depth=1 https://github.com/MichaelAquilina/zsh-you-should-use.git ~/.oh-my-zsh/custom/plugins/zsh-you-should-use
  echo "zsh-you-should-use installed."
fi

# --- Write .zshrc ---

echo "[5/6] Downloading ~/.zshrc..."
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/zshrc -o ~/.zshrc
echo ".zshrc written."

# --- Change default shell ---

echo "[6/6] Setting zsh as default shell..."
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
echo "  2. Powerlevel10k configuration wizard will launch on first start"
