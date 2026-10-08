#!/usr/bin/env bash
#
# build-macos.sh - Build fnmap for macOS desktop
#
# Usage:
#   ./build-macos.sh [--debug|--release] [--dmg] [-r|--run]
#
# Flags:
#   -d, --debug    Build in debug mode (faster build, debug symbols)
#       --release  Build in release mode (default, optimized)
#       --dmg      Create a distributable .dmg disk image installer
#   -r, --run      Launch fnmap.app immediately after building
#   -h, --help     Show this help message

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_ROOT}"

# If xcode-select points to CommandLineTools, automatically use Xcode.app
if [[ "$(xcode-select -p 2>/dev/null || true)" == *"/CommandLineTools"* ]] && [[ -d "/Applications/Xcode.app/Contents/Developer" ]]; then
  export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi

BUILD_MODE="release"
CREATE_DMG=false
DO_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--debug)
      BUILD_MODE="debug"
      shift
      ;;
    --release)
      BUILD_MODE="release"
      shift
      ;;
    --dmg)
      CREATE_DMG=true
      shift
      ;;
    -r|--run)
      DO_RUN=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [--debug|--release] [--dmg] [-r|--run]"
      echo ""
      echo "Options:"
      echo "  -d, --debug    Build in debug mode"
      echo "      --release  Build in release mode (default)"
      echo "      --dmg      Create a distributable .dmg disk image"
      echo "  -r, --run      Launch fnmap.app immediately after building"
      echo "  -h, --help     Show this help message"
      exit 0
      ;;
    *)
      echo "Error: Unknown argument '$1'" >&2
      echo "Usage: $0 [--debug|--release] [--dmg] [-r|--run]" >&2
      exit 1
      ;;
  esac
done

echo "=========================================="
echo "Building fnmap for macOS (${BUILD_MODE})"
echo "=========================================="

echo "==> [1/3] Building Flutter macOS bundle..."
if [[ "${BUILD_MODE}" == "release" ]]; then
  flutter build macos --release
  APP_PATH="${PROJECT_ROOT}/build/macos/Build/Products/Release/fnmap.app"
else
  flutter build macos --debug
  APP_PATH="${PROJECT_ROOT}/build/macos/Build/Products/Debug/fnmap.app"
fi

echo "==> [2/3] Build completed successfully: ${APP_PATH}"

if [[ "${CREATE_DMG}" == "true" ]]; then
  echo "==> [3/3] Packaging .dmg disk image..."
  DMG_STAGING="${PROJECT_ROOT}/build/macos/dmg_staging"
  DMG_OUTPUT="${PROJECT_ROOT}/fnmap-macos.dmg"

  rm -rf "${DMG_STAGING}" "${DMG_OUTPUT}"
  mkdir -p "${DMG_STAGING}"

  cp -R "${APP_PATH}" "${DMG_STAGING}/"
  ln -s /Applications "${DMG_STAGING}/Applications"

  hdiutil create -volname "fnmap" -srcfolder "${DMG_STAGING}" -ov -format UDZO "${DMG_OUTPUT}"
  rm -rf "${DMG_STAGING}"

  echo "=========================================="
  echo "Disk image created: ${DMG_OUTPUT}"
  echo "=========================================="
else
  echo "==> [3/3] Done!"
fi

if [[ "${DO_RUN}" == "true" ]]; then
  echo ""
  echo "==> Launching fnmap..."
  open "${APP_PATH}"
fi
