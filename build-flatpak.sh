#!/usr/bin/env bash
#
# build-flatpak.sh - Build the fnmap Flatpak package
#
# Usage:
#   ./build-flatpak.sh [-i|--install] [-r|--run]
#
# Flags:
#   -i, --install  Install the flatpak locally into user environment after building
#   -r, --run      Build, install, and run fnmap via Flatpak immediately
#   -h, --help     Show this help message

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_ROOT}"

APP_ID="com.krioltech.fnmap"
RUNTIME="org.freedesktop.Platform"
RUNTIME_VERSION="25.08"

# Detect app version from pubspec.yaml or lib/constants.dart
APP_VERSION=""
if [[ -f "${PROJECT_ROOT}/pubspec.yaml" ]]; then
  APP_VERSION="$(grep '^version:' "${PROJECT_ROOT}/pubspec.yaml" | head -n 1 | awk '{print $2}' | cut -d'+' -f1)"
fi
if [[ -z "${APP_VERSION}" ]] && [[ -f "${PROJECT_ROOT}/lib/constants.dart" ]]; then
  APP_VERSION="$(grep -o "kAppVersion = '[^']*'" "${PROJECT_ROOT}/lib/constants.dart" | cut -d"'" -f2)"
fi
APP_VERSION="${APP_VERSION:-1.4.1}"

# Detect host architecture and map to standard platform string (x86_64 -> amd64, aarch64 -> arm64)
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64)  PLATFORM="amd64" ;;
  aarch64) PLATFORM="arm64" ;;
  armv7l)  PLATFORM="armhf" ;;
  *)       PLATFORM="${ARCH}" ;;
esac

DO_INSTALL=false
DO_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--install)
      DO_INSTALL=true
      shift
      ;;
    -r|--run)
      DO_INSTALL=true
      DO_RUN=true
      shift
      ;;
    -v|--version)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --version requires a version argument" >&2
        exit 1
      fi
      APP_VERSION="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [-i|--install] [-r|--run] [-v|--version <version>]"
      echo ""
      echo "Options:"
      echo "  -i, --install          Install the flatpak locally for the current user after building"
      echo "  -r, --run              Install and run fnmap via Flatpak immediately"
      echo "  -v, --version <ver>    Override app version (default: auto-detected from pubspec.yaml)"
      echo "  -h, --help             Show this help message"
      exit 0
      ;;
    *)
      echo "Error: Unknown argument '$1'" >&2
      echo "Usage: $0 [-i|--install] [-r|--run] [-v|--version <version>]" >&2
      exit 1
      ;;
  esac
done

BUNDLE_OUTPUT="fnmap_${APP_VERSION}_${PLATFORM}.flatpak"

echo "=========================================="
echo "Building Flatpak: ${APP_ID}"
echo "Package Output:   ${BUNDLE_OUTPUT}"
echo "=========================================="

echo "==> [1/6] Building Flutter Linux release bundle..."
flutter build linux --release

BUILD_DIR="${PROJECT_ROOT}/build/flatpak"
APP_DIR="${BUILD_DIR}/app"
REPO_DIR="${BUILD_DIR}/repo"

echo "==> [2/6] Preparing Flatpak build directory..."
rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}" "${REPO_DIR}"

echo "==> [3/6] Initializing Flatpak environment..."
flatpak build-init "${APP_DIR}" "${APP_ID}" "${RUNTIME}" "${RUNTIME}" "${RUNTIME_VERSION}"

echo "==> [4/6] Installing application files into Flatpak prefix (/app)..."
mkdir -p "${APP_DIR}/files/fnmap"
cp -r build/linux/x64/release/bundle/* "${APP_DIR}/files/fnmap/"

mkdir -p "${APP_DIR}/files/bin"
ln -sf "../fnmap/fnmap" "${APP_DIR}/files/bin/fnmap"

# Bundle nmap if available from cache or flatpak-builder build-dir
NMAP_BIN=""
NMAP_SHARE=""
if [[ -f "${PROJECT_ROOT}/build/flatpak-cache/nmap/nmap" ]]; then
  NMAP_BIN="${PROJECT_ROOT}/build/flatpak-cache/nmap/nmap"
  NMAP_SHARE="${PROJECT_ROOT}/build/flatpak-cache/nmap/share/nmap"
elif [[ -f "${PROJECT_ROOT}/../com.krioltech.fnmap/build-dir/files/bin/nmap" ]]; then
  NMAP_BIN="${PROJECT_ROOT}/../com.krioltech.fnmap/build-dir/files/bin/nmap"
  NMAP_SHARE="${PROJECT_ROOT}/../com.krioltech.fnmap/build-dir/files/share/nmap"
fi

if [[ -n "${NMAP_BIN}" ]] && [[ -f "${NMAP_BIN}" ]]; then
  echo "==> Bundling nmap into Flatpak prefix (/app/bin/nmap)..."
  cp -a "${NMAP_BIN}" "${APP_DIR}/files/bin/"
  if [[ -f "${NMAP_BIN%/*}/ncat" ]]; then
    cp -a "${NMAP_BIN%/*}/ncat" "${APP_DIR}/files/bin/" 2>/dev/null || true
  fi
  if [[ -f "${NMAP_BIN%/*}/nping" ]]; then
    cp -a "${NMAP_BIN%/*}/nping" "${APP_DIR}/files/bin/" 2>/dev/null || true
  fi
  if [[ -d "${NMAP_SHARE}" ]]; then
    mkdir -p "${APP_DIR}/files/share"
    cp -a "${NMAP_SHARE}" "${APP_DIR}/files/share/"
  fi
fi

# Desktop integration
mkdir -p "${APP_DIR}/files/share/applications"
install -m 644 flatpak/com.krioltech.fnmap.desktop "${APP_DIR}/files/share/applications/${APP_ID}.desktop"

mkdir -p "${APP_DIR}/files/share/metainfo"
install -m 644 flatpak/com.krioltech.fnmap.metainfo.xml "${APP_DIR}/files/share/metainfo/${APP_ID}.metainfo.xml"

mkdir -p "${PROJECT_ROOT}/assets/icons"
for s in 16 24 32 48 64 128 256 512; do
  if [[ ! -f "${PROJECT_ROOT}/assets/icons/${s}x${s}.png" ]]; then
    convert "${PROJECT_ROOT}/assets/fnmap.png" -resize ${s}x${s} "${PROJECT_ROOT}/assets/icons/${s}x${s}.png"
  fi
  mkdir -p "${APP_DIR}/files/share/icons/hicolor/${s}x${s}/apps"
  install -m 644 "${PROJECT_ROOT}/assets/icons/${s}x${s}.png" "${APP_DIR}/files/share/icons/hicolor/${s}x${s}/apps/${APP_ID}.png"
done

echo "==> [5/6] Finalizing Flatpak sandbox permissions..."
flatpak build-finish "${APP_DIR}" \
  --command=fnmap \
  --filesystem=home \
  --filesystem=/tmp \
  --share=network \
  --share=ipc \
  --socket=x11 \
  --socket=wayland \
  --socket=fallback-x11 \
  --device=dri

echo "==> [6/6] Exporting to local repository and building .flatpak bundle..."
flatpak build-export "${REPO_DIR}" "${APP_DIR}"
flatpak build-bundle "${REPO_DIR}" "${PROJECT_ROOT}/${BUNDLE_OUTPUT}" "${APP_ID}"

echo ""
echo "=========================================="
echo "Flatpak build successful!"
echo "Bundle file created: ${PROJECT_ROOT}/${BUNDLE_OUTPUT}"
echo "=========================================="

if [[ "${DO_INSTALL}" == "true" ]]; then
  echo ""
  echo "==> Installing ${APP_ID} into local user Flatpak repository..."
  flatpak --user remote-add --no-gpg-verify --if-not-exists fnmap-local-repo "${REPO_DIR}"
  flatpak --user install -y --reinstall fnmap-local-repo "${APP_ID}"

  echo "==> Updating desktop icon themes and application caches..."
  for s in 16 24 32 48 64 128 256 512; do
    mkdir -p "${HOME}/.local/share/icons/hicolor/${s}x${s}/apps"
    install -m 644 "${PROJECT_ROOT}/assets/icons/${s}x${s}.png" "${HOME}/.local/share/icons/hicolor/${s}x${s}/apps/${APP_ID}.png"
  done
  gtk-update-icon-cache -f -t "${HOME}/.local/share/icons/hicolor" 2>/dev/null || true
  gtk-update-icon-cache -f -t "${HOME}/.local/share/flatpak/exports/share/icons/hicolor" 2>/dev/null || true
  kbuildsycoca6 2>/dev/null || kbuildsycoca5 2>/dev/null || true
  echo "Installation and icon cache update complete!"
fi

if [[ "${DO_RUN}" == "true" ]]; then
  echo ""
  echo "==> Launching ${APP_ID} via Flatpak..."
  flatpak run "${APP_ID}"
else
  echo ""
  echo "To install and test manually, run:"
  echo "  flatpak install --user --bundle ${BUNDLE_OUTPUT}"
  echo ""
  echo "To run:"
  echo "  flatpak run ${APP_ID}"
fi
