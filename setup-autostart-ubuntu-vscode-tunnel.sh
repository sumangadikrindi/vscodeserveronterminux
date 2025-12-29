#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# ------------------------------
# User-tunable options
# ------------------------------
TUNNEL_NAME="my-terminux-ubuntu"
TUNNEL_PROVIDER="github"   # change to "microsoft" if you want Microsoft login
UBUNTU_LOCALE="en_US.UTF-8"

echo "[1/9] Updating Termux and installing prerequisites..."
apt-get update -yq 
apt-get upgrade -yq
apt-get install -yq wget tar curl nano
echo "[1.2/9] Reinstalling proot-distro..."
pkg reinstall -y proot-distro

echo "[2/9] Installing Ubuntu (proot-distro)..."
proot-distro install ubuntu

echo "[3/9] Entering Ubuntu and installing VS Code CLI + .NET SDK + Git..."
proot-distro login ubuntu -- bash -lc '
set -e

echo "[Ubuntu] Updating packages..."
apt update && apt upgrade -y
apt install -y wget tar curl ca-certificates locales git openssh-client

echo "[Ubuntu] Setting UTF-8 locale..."
locale-gen '"$UBUNTU_LOCALE"' || true
update-locale LANG='"$UBUNTU_LOCALE"' || true

echo "[Ubuntu] Downloading VS Code CLI..."
wget -q https://update.code.visualstudio.com/latest/cli-linux-arm64/stable -O /tmp/vscode-cli.tar.gz
mkdir -p /usr/local/bin
tar -xzf /tmp/vscode-cli.tar.gz -C /usr/local/bin
chmod +x /usr/local/bin/code

echo "[Ubuntu] Installing latest .NET SDK..."
wget -q https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh
bash /tmp/dotnet-install.sh --channel LTS --install-dir /usr/local/dotnet
ln -sf /usr/local/dotnet/dotnet /usr/local/bin/dotnet

echo "[Ubuntu] Verifying .NET install..."
dotnet --info || true

echo "[Ubuntu] Configuring Git user details..."
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"

echo "[Ubuntu] Preparing log directory..."
mkdir -p "$HOME/.cache"

echo "[Ubuntu] Updating ~/.bashrc with .NET GC tuning (no tunnel auto-start yet)..."
if ! grep -q "# --- VS Code Tunnel & .NET GC tuning ---" "$HOME/.bashrc"; then
  cat >> "$HOME/.bashrc" <<'"EOFUBUNTU"'
# --- VS Code Tunnel & .NET GC tuning ---
export LANG=en_US.UTF-8
export DOTNET_GCHeapHardLimit=0x10000000   # 256 MiB
export DOTNET_GCServer=0                   # workstation GC
export DOTNET_EnableDiagnostics=0          # optional
# (Tunnel auto-start will be appended later after first-run login)
EOFUBUNTU
fi

echo "[Ubuntu] Setup inside Ubuntu (core tools) complete."
'

echo "[4/9] Configuring Termux to auto-login to Ubuntu..."
if ! grep -q "proot-distro login ubuntu" "$HOME/.bashrc"; then
  cat >> "$HOME/.bashrc" <<'EOFTERMUX'
# Auto-login to Ubuntu
proot-distro login ubuntu
EOFTERMUX
fi

echo "[5/9] Notes:"
echo "  • On first tunnel run, you must complete device-code sign-in (GitHub by default)."
echo "  • After the first login, the script will enable auto-start inside Ubuntu's ~/.bashrc."
echo "  • To bypass Termux auto-login: run termux-failsafe."

echo "[6/9] Preparing tunnel first-run in Ubuntu..."
proot-distro login ubuntu -- bash -lc "
set -e
# Create a helper script for first-run tunnel login + start
echo "[6.1/9] Creating helper script directory"
mkdir -p \$HOME/.local/bin
echo "[6.2/9] Creating helper script"
cat > \$HOME/.local/bin/first_run_tunnel.sh <<'EOF_FIRST'
#!/usr/bin/env bash
set -euo pipefail

PROVIDER='${TUNNEL_PROVIDER}'
NAME='${TUNNEL_NAME}'
LOG_DIR=\"\$HOME/.cache\"
LOG_FILE=\"\$LOG_DIR/code-tunnel.log\"
mkdir -p \"\$LOG_DIR\"

echo \"[Ubuntu] Performing one-time login with provider: \$PROVIDER...\"
if [ \"\$PROVIDER\" = \"microsoft\" ]; then
  code tunnel user login --provider microsoft
else
  # github is default; explicit login makes intent clear
  code tunnel user login --provider github
fi

echo \"[Ubuntu] Starting VS Code Tunnel (name: \$NAME) to complete first-run...\"
# Start in foreground to ensure device-code flow and initial setup complete
code tunnel --name \"\$NAME\" --accept-server-license-terms | tee \"\$LOG_FILE\"

echo \"[Ubuntu] Appending auto-start block to ~/.bashrc...\"
if ! grep -q \"code tunnel\" \"\$HOME/.bashrc\"; then
  cat >> \"\$HOME/.bashrc\" <<'EOF_AUTOSTART'
# Auto-start VS Code Tunnel after interactive shells
if [[ \$- == *i* ]]; then
  if ! pgrep -f \"code tunnel\" >/dev/null 2>&1; then
    echo \"Starting VS Code Tunnel...\"
    nohup code tunnel --accept-server-license-terms \
      >\"\$HOME/.cache/code-tunnel.log\" 2>&1 &
  fi
fi
EOF_AUTOSTART
fi

echo \"[Ubuntu] First-run tunnel login complete. Auto-start enabled.\"
EOF_FIRST
echo "[6.3/9] Setting script file as executable..."
chmod +x \$HOME/.local/bin/first_run_tunnel.sh
"

echo "[7/9] Run the first-run tunnel helper (this will ask you to sign in once)..."
proot-distro login ubuntu -- bash -lc '~/.local/bin/first_run_tunnel.sh'

echo "[8/9] Tunnel auto-start has been appended to Ubuntu ~/.bashrc."
echo "      Next time you open Termux → auto-login to Ubuntu → tunnel starts automatically."

echo "[9/9] Final tips:"
echo "  • Tunnel logs (inside Ubuntu): ~/.cache/code-tunnel.log"
echo "  • Stop tunnel manually: pkill -f \"code tunnel\""
echo "  • On desktop VS Code, install: 'Remote - Tunnels' and (optional) 'C# Dev Kit'"
echo "  • Connect to the tunnel and start coding!"
echo "Script complete."
