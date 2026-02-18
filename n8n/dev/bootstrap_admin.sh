#!/usr/bin/env bash
set -euo pipefail

ADMIN_USER="${1:-admin}"

# Must run as root
if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Run as root (sudo bash $0 ${ADMIN_USER})" >&2
  exit 1
fi

# Ensure sudo group exists (Debian/Ubuntu)
if ! getent group sudo >/dev/null; then
  echo "ERROR: 'sudo' group not found. Are you on Debian/Ubuntu?" >&2
  exit 1
fi

# Ensure root has an authorized_keys to copy
ROOT_AK="/root/.ssh/authorized_keys"
if [[ ! -f "${ROOT_AK}" ]]; then
  echo "ERROR: ${ROOT_AK} not found. Root key auth may not be configured." >&2
  exit 1
fi

# Create user if missing
if id "${ADMIN_USER}" >/dev/null 2>&1; then
  echo "User '${ADMIN_USER}' already exists."
else
  echo "Creating user '${ADMIN_USER}'..."
  # Creates home dir, prompts for password. If you want no prompt, see note below.
  adduser "${ADMIN_USER}"
fi

# Add to sudo group (safe if already a member)
echo "Adding '${ADMIN_USER}' to sudo group..."
usermod -aG sudo "${ADMIN_USER}"

# Setup SSH directory and authorized_keys
ADMIN_HOME="$(getent passwd "${ADMIN_USER}" | cut -d: -f6)"
ADMIN_SSH="${ADMIN_HOME}/.ssh"
ADMIN_AK="${ADMIN_SSH}/authorized_keys"

echo "Setting up SSH keys for '${ADMIN_USER}' in ${ADMIN_AK}..."
mkdir -p "${ADMIN_SSH}"
chmod 700 "${ADMIN_SSH}"

# Copy root authorized_keys if admin doesn't already have it
if [[ -f "${ADMIN_AK}" ]]; then
  echo "authorized_keys already exists for '${ADMIN_USER}'. Merging keys (no duplicates)..."
  tmp="$(mktemp)"
  cat "${ADMIN_AK}" "${ROOT_AK}" | awk '!seen[$0]++' > "${tmp}"
  cat "${tmp}" > "${ADMIN_AK}"
  rm -f "${tmp}"
else
  cp "${ROOT_AK}" "${ADMIN_AK}"
fi

chown -R "${ADMIN_USER}:${ADMIN_USER}" "${ADMIN_SSH}"
chmod 600 "${ADMIN_AK}"

echo "Done."
echo "Test from your laptop:"
echo "  ssh ${ADMIN_USER}@<SERVER_IP> -i <PATH_TO_KEY>"
