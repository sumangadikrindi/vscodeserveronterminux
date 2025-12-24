
#!/usr/bin/env bash
set -euo pipefail

echo "[GitAuth] Starting Git authentication setup..."

# Prompt for Git identity

GIT_USER_NAME=""
GIT_USER_EMAIL=""
KEY_COMMENT=""
PASSPHRASE=""

read -rp "Enter your Git user.name: " GIT_USER_NAME </dev/tty
read -rp "Enter your Git user.email: " GIT_USER_EMAIL </dev/tty
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

# Generate SSH key (Ed25519)
SSH_DIR="$HOME/.ssh"
KEY_FILE="$SSH_DIR/id_ed25519"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [[ -f "$KEY_FILE" || -f "$KEY_FILE.pub" ]]; then
  echo "[GitAuth] Existing key detected at $KEY_FILE(.pub)."
  read -rp "Overwrite existing key? (y/N): " OVERWRITE
  if [[ "${OVERWRITE,,}" == "y" ]]; then
    rm -f "$KEY_FILE" "$KEY_FILE.pub"
  else
    echo "[GitAuth] Keeping existing key."
  fi
fi

if [[ ! -f "$KEY_FILE" ]]; then
  read -rp "Enter comment for SSH key (usually your email): " KEY_COMMENT </dev/tty
  read -rsp "Enter passphrase (leave empty for no passphrase): " PASSPHRASE </dev/tty
  echo
  ssh-keygen -t ed25519 -C "${KEY_COMMENT:-$GIT_USER_EMAIL}" -f "$KEY_FILE" -N "${PASSPHRASE:-}"
  echo "[GitAuth] SSH key generated."
fi

chmod 600 "$KEY_FILE"
chmod 644 "$KEY_FILE.pub"

echo
echo "============================================================"
echo "Add this SSH PUBLIC KEY to GitHub (Settings → SSH and GPG keys):"
echo
cat "$KEY_FILE.pub"
echo
echo "============================================================"
echo "Test GitHub SSH connectivity:"
echo "  ssh -T git@github.com"
echo "[GitAuth] Completed."
