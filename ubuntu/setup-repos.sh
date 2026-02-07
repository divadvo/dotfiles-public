#!/usr/bin/env bash
set -euo pipefail

# Authenticate with GitHub CLI, create project directories, and clone repos
# Run as normal user (not root)

echo "=== GitHub Repos Setup ==="

if [[ $EUID -eq 0 ]]; then
  echo "ERROR: Do not run as root. Run as your normal user."
  exit 1
fi

# --- Check gh is installed ---

if ! command -v gh &> /dev/null; then
  echo "ERROR: gh (GitHub CLI) is not installed. Run setup-packages.sh first."
  exit 1
fi

# --- Authenticate ---

echo "[1/4] Checking GitHub authentication..."
if gh auth status &> /dev/null; then
  echo "Already authenticated."
else
  HOSTNAME=$(hostname)
  echo "Not authenticated. Run this from your Mac to send your token:"
  echo ""
  echo "  gh auth token | ssh divadvo@${HOSTNAME} 'gh auth login --with-token && gh config set -h github.com git_protocol https'"
  echo ""
  echo "Then re-run this script."
  exit 1
fi

# --- Create directory structure ---

echo "[2/4] Creating directory structure..."
mkdir -p ~/pr/github ~/pr/github-other ~/pr/sandbox
echo "Directories created."

# --- Clone priority repos ---

echo "[3/4] Cloning priority repos..."
PRIORITY_REPOS=(
  "divadvo/divadvo-scripts"
)

for repo in "${PRIORITY_REPOS[@]}"; do
  name="${repo#*/}"
  if [[ -d ~/pr/github/"$name" ]]; then
    echo "  $repo — already exists, skipping."
  else
    gh repo clone "$repo" ~/pr/github/"$name"
    echo "  $repo — cloned."
  fi
done

# --- Clone recent repos (parallel) ---

echo "[4/4] Cloning recent repos..."
REPOS_TO_CLONE=()

while IFS= read -r repo; do
  name="${repo#*/}"

  # Skip priority repos (already cloned above)
  skip=false
  for p in "${PRIORITY_REPOS[@]}"; do
    [[ "$p" == "$repo" ]] && skip=true && break
  done
  $skip && continue

  [[ -d ~/pr/github/"$name" ]] && continue
  REPOS_TO_CLONE+=("$repo")
done < <(gh repo list --limit 10 --json nameWithOwner --jq '.[].nameWithOwner')

# Clone in parallel
for repo in "${REPOS_TO_CLONE[@]}"; do
  name="${repo#*/}"
  gh repo clone "$repo" ~/pr/github/"$name" &
done
wait

echo "  Cloned ${#REPOS_TO_CLONE[@]} repo(s)."

echo ""
echo "=== Repos Setup Complete ==="
echo ""
echo "Directory structure:"
echo "  ~/pr/github/       — your repositories"
echo "  ~/pr/github-other/ — external repositories"
echo "  ~/pr/sandbox/      — experimental projects"
