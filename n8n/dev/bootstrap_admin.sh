#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   sudo bash bootstrap_admin.sh [admin_username]
#
# Example:
#   sudo bash bootstrap_admin.sh admin

ADMIN_USER="${1:-admin}"

# --- sanity checks ---
if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Run as root: sudo bash $0 ${ADMIN_USER}" >&2
  exit 1
fi

if ! command -v useradd >/dev/null 2>&1; then
  echo "ERROR: useradd not found. This script expects a typical Linux distro (Debian/Ubuntu etc.)." >&2
  exit 1
fi

if ! getent group sudo >/dev/null 2>&1; then
  echo "ERROR: 'sudo' group not found. On some distros the admin group is 'wheel'." >&2
  exit 1
fi

ROOT_AK="/root/.ssh/authorized_keys"
if [[ ! -f "${ROOT_AK}" ]]; then
  echo "ERROR: ${ROOT_AK} not found. Root key auth doesn't appear configured." >&2
  exit 1
fi

# --- create user if missing (non-interactive) ---
if id "${ADMIN_USER}" >/dev/null 2>&1; then
  echo "User '${ADMIN_USER}' already exists."
else
  echo "Creating user '${ADMIN_USER}' (non-interactive)..."
  useradd -m -s /bin/bash "${ADMIN_USER}"
  echo "Locking password for '${ADMIN_USER}'..."
  passwd -l "${ADMIN_USER}" >/dev/null
fi

# --- grant sudo ---
echo "Ensuring '${ADMIN_USER}' is in sudo group..."
usermod -aG sudo "${ADMIN_USER}"

# --- set up SSH authorized_keys ---
ADMIN_HOME="$(getent passwd "${ADMIN_USER}" | cut -d: -f6)"
if [[ -z "${ADMIN_HOME}" || ! -d "${ADMIN_HOME}" ]]; then
  echo "ERROR: Could not determine home directory for '${ADMIN_USER}'." >&2
  exit 1
fi

ADMIN_SSH="${ADMIN_HOME}/.ssh"
ADMIN_AK="${ADMIN_SSH}/authorized_keys"

echo "Configuring SSH keys for '${ADMIN_USER}'..."
mkdir -p "${ADMIN_SSH}"
chmod 700 "${ADMIN_SSH}"

# If authorized_keys already exists, merge without duplicates; otherwise copy.
if [[ -f "${ADMIN_AK}" ]]; then
  echo "authorized_keys exists. Merging root keys (dedupe)..."
  tmp="$(mktemp)"
  cat "${ADMIN_AK}" "${ROOT_AK}" | awk 'NF && !seen[$0]++' > "${tmp}"
  cat "${tmp}" > "${ADMIN_AK}"
  rm -f "${tmp}"
else
  cp "${ROOT_AK}" "${ADMIN_AK}"
fi

chown -R "${ADMIN_USER}:${ADMIN_USER}" "${ADMIN_SSH}"
chmod 600 "${ADMIN_AK}"

echo
echo "DONE."
echo "Test from your laptop:"
echo "  ssh ${ADMIN_USER}@<SERVER_IP> -i <PATH_TO_PRIVATE_KEY>"
echo
echo "Then you can become root (recommended instead of root SSH):"
echo "  sudo -i"
