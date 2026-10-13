#!/usr/bin/env bash
#
# clean-flatpak.sh - Clean Flatpak build artifacts and optionally uninstall local testing Flatpak
#

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_ROOT}"

APP_ID="com.krioltech.fnmap"

echo "=========================================="
echo "Cleaning Flatpak build artifacts"
echo "=========================================="

echo "==> Removing Flatpak build directory..."
rm -rf "${PROJECT_ROOT}/build/flatpak"

if compgen -G "${PROJECT_ROOT}/fnmap_*.flatpak" >/dev/null; then
  echo "==> Removing generated Flatpak bundles (fnmap_*.flatpak)..."
  rm -f "${PROJECT_ROOT}"/fnmap_*.flatpak
fi

if compgen -G "${PROJECT_ROOT}/fnmap-*.x64.tar.gz" >/dev/null; then
  echo "==> Removing generated Flathub release archives (fnmap-*.x64.tar.gz)..."
  rm -f "${PROJECT_ROOT}"/fnmap-*.x64.tar.gz
fi

# If installed in user remotes, optionally remove
if flatpak --user list | grep -q "${APP_ID}"; then
  echo "==> Uninstalling ${APP_ID} from user Flatpak installation..."
  flatpak --user uninstall -y "${APP_ID}" || true
fi

if flatpak --user remotes | grep -q "fnmap-local-repo"; then
  echo "==> Removing fnmap-local-repo remote..."
  flatpak --user remote-delete fnmap-local-repo || true
fi

echo "==> Cleaning user hicolor icons for ${APP_ID}..."
for s in 16 24 32 48 64 128 256 512; do
  rm -f "${HOME}/.local/share/icons/hicolor/${s}x${s}/apps/${APP_ID}.png"
done
gtk-update-icon-cache -f -t "${HOME}/.local/share/icons/hicolor" 2>/dev/null || true
kbuildsycoca6 2>/dev/null || kbuildsycoca5 2>/dev/null || true

echo "=========================================="
echo "Flatpak artifacts cleaned successfully!"
echo "=========================================="
