#!/usr/bin/env bash
set -euo pipefail

# Setup xRDP + XFCE remote desktop on Ubuntu 24.04
# Run manually on the server as a normal user (not root)
# Connect from macOS using Microsoft Remote Desktop

echo "=== Remote Desktop Setup (xRDP + XFCE) ==="
echo ""

# --- Source shared lib ---

_LIB="/tmp/.ubuntu-setup-lib.sh"
[[ -f "$_LIB" ]] || curl -fsSL https://raw.githubusercontent.com/divadvo/dotfiles-public/main/ubuntu/lib.sh -o "$_LIB"
source "$_LIB"

# --- Pre-flight checks ---

if [[ $EUID -eq 0 ]]; then
  echo "ERROR: Do not run as root. Run as your normal user (sudo will be used where needed)."
  exit 1
fi

if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
  echo "WARNING: This script is designed for Ubuntu. Proceeding anyway..."
fi

# --- Password setup (required for xRDP login) ---

echo "[1/6] Checking password..."
PASSWD_STATUS=$(sudo passwd -S "$USER" | awk '{print $2}')
if [[ "$PASSWD_STATUS" == "L" || "$PASSWD_STATUS" == "NP" ]]; then
  echo "xRDP requires a password for login. Please set one now:"
  sudo passwd "$USER" < /dev/tty
  echo ""
else
  echo "Password already set."
fi

# --- Install XFCE ---

echo "[2/7] Installing XFCE desktop environment..."
apt_update_if_stale
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq xfce4 xfce4-goodies dbus-x11 > /dev/null
echo "XFCE installed."

# --- Install xRDP ---

echo "[3/7] Installing xRDP..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq xrdp > /dev/null
sudo adduser xrdp ssl-cert 2>/dev/null || true
echo "xRDP installed."

# --- Configure xRDP to use XFCE ---

echo "[4/7] Configuring xRDP session..."

# Per-user session config
echo "startxfce4" > ~/.xsession
chmod +x ~/.xsession

# System-wide fallback: ensure startwm.sh tries xfce4
if ! grep -q "startxfce4" /etc/xrdp/startwm.sh; then
  sudo sed -i '/^test -x \/etc\/X11\/Xsession/i # Start XFCE for xRDP sessions\nif [ -r ~/.xsession ]; then\n  . ~/.xsession\n  exit 0\nfi' /etc/xrdp/startwm.sh
fi

echo "Session configured."

# --- Fix Ubuntu 24.04 polkit popups ---

echo "[5/7] Applying polkit fixes..."

# Install polkitd-pkla (Ubuntu 24.04 uses JS rules by default, pkla is simpler for these overrides)
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq polkitd-pkla 2>/dev/null || true

sudo mkdir -p /etc/polkit-1/localauthority/50-local.d

# Fix "Authentication required to create a color profile/managed device"
sudo tee /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla > /dev/null << 'EOF'
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

# Fix "Authentication required to refresh system repositories"
sudo tee /etc/polkit-1/localauthority/50-local.d/46-allow-packagekit.pkla > /dev/null << 'EOF'
[Allow PackageKit all Users]
Identity=unix-user:*
Action=org.freedesktop.packagekit.system-sources-refresh
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF

echo "Polkit fixes applied."

# --- Enable and start xRDP ---

# --- Install Orchis theme ---

echo "[6/7] Installing Orchis theme..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq gtk2-engines-murrine sassc > /dev/null
ORCHIS_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/vinceliuice/Orchis-theme.git "$ORCHIS_DIR"
"$ORCHIS_DIR/install.sh"
rm -rf "$ORCHIS_DIR"

# Apply theme to XFCE
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml
cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'XEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Orchis"/>
    <property name="IconThemeName" type="string" value="Adwaita"/>
  </property>
</channel>
XEOF

echo "Orchis theme installed and applied."

# --- Enable and start xRDP ---

echo "[7/7] Starting xRDP service..."
sudo systemctl enable xrdp --now
sudo systemctl restart xrdp
echo "xRDP is running."

# --- Done ---

TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "<tailscale-ip>")
TAILSCALE_HOSTNAME=$(tailscale status --self --json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['Self']['DNSName'].rstrip('.'))" 2>/dev/null || echo "<tailscale-hostname>")

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Connect from macOS:"
echo "  1. Install 'Microsoft Remote Desktop' from the Mac App Store"
echo "  2. Add a PC with one of these addresses:"
echo "     - Tailscale IP:       $TAILSCALE_IP"
echo "     - Tailscale hostname: $TAILSCALE_HOSTNAME"
echo "  3. Login with:"
echo "     - Username: $USER"
echo "     - Password: (the password you set during this setup)"
echo ""
echo "No firewall changes needed — RDP traffic travels through Tailscale."
