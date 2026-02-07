# Ubuntu Setup Scripts

## Interactive Setup (pick & run)

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/setup-all.sh | bash
```

## Monitor Cloud-init

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/monitor-cloud-init.sh | bash
```

## Manual Scripts

### Gum (CLI toolkit)

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/setup-gum.sh | bash
```

### Zsh + Oh My Zsh + Powerlevel10k

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/setup-zsh.sh | bash
```

### GitHub Repos

First, send your GitHub auth from your Mac:

```bash
gh auth token | ssh divadvo@dh1 'gh auth login --with-token && gh config set -h github.com git_protocol https'
```

Then on the server:

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/setup-repos.sh | bash
```

### Google Chrome

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/setup-chrome.sh | sudo bash
```

### Remote Desktop (xRDP + XFCE)

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/setup-remote-desktop.sh | bash
```

## Cloud-init Scripts (automatic)

These run automatically during server provisioning via `cloud-init.yml.tftpl`.

### Tailscale + UFW

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/cloud-init/setup-tailscale.sh | sudo bash -s -- --auth-key=YOUR_KEY --ufw --ssh --exit-node
```

### System Packages

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/cloud-init/setup-packages.sh | sudo bash
```

### Docker

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/cloud-init/setup-docker.sh | sudo bash -s -- USERNAME
```

### Dev Tools (uv, mise, node, bun)

```bash
curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/cloud-init/setup-dev-tools.sh | bash
```
