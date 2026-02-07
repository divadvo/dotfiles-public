# Ubuntu Setup Scripts

## Remote Desktop (xRDP + XFCE)

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/setup-remote-desktop.sh | bash
```

## System Packages

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/setup-packages.sh | sudo bash
```

## Tailscale + UFW

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/setup-tailscale.sh | sudo bash -s -- --auth-key=YOUR_KEY --ufw --ssh --exit-node
```

## Docker

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/setup-docker.sh | sudo bash -s -- USERNAME
```

## Google Chrome

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/setup-chrome.sh | sudo bash
```

## Zsh + Oh My Zsh + Powerlevel10k

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/setup-zsh.sh | bash
```

## GitHub Repos

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/setup-repos.sh | bash
```

## Dev Tools (uv, mise, node, bun)

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/setup-dev-tools.sh | bash
```
