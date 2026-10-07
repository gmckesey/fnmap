#!/usr/bin/env bash
#
# build-snap.sh - Build the fnmap Snap package
#
# Usage:
#   ./build-snap.sh [-t|--test | -p|--production]
#
# Defaults to -t (local test) if no argument is provided.

set -euo pipefail

# Ensure we run from the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_ROOT}"

# Default mode is test
MODE="test"

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--test)
      MODE="test"
      shift
      ;;
    -p|--production)
      MODE="production"
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [-t|--test | -p|--production]"
      echo ""
      echo "Options:"
      echo "  -t, --test        Build snap for local testing (uses --destructive-mode, default)"
      echo "  -p, --production  Build snap for distribution on the Snap Store (isolated build)"
      echo "  -h, --help        Show this help message"
      exit 0
      ;;
    *)
      echo "Error: Unknown argument '$1'" >&2
      echo "Usage: $0 [-t|--test | -p|--production]" >&2
      exit 1
      ;;
  esac
done

echo "=========================================="
if [[ "${MODE}" == "test" ]]; then
  echo "Building Snap in TEST mode (local test)"
else
  echo "Building Snap in PRODUCTION mode (Snap Store)"
fi
echo "=========================================="

echo "==> [1/2] Cleaning build and Snapcraft working directories..."
flutter clean
if ! rm -rf parts stage prime .snapcraft 2>/dev/null; then
  if command -v docker >/dev/null 2>&1; then
    docker run --rm -v "${PROJECT_ROOT}:/project" -w /project alpine rm -rf parts stage prime .snapcraft 2>/dev/null || true
  fi
fi

echo "==> [2/2] Packaging the snap..."
if [[ "${MODE}" == "test" ]]; then
  if command -v docker >/dev/null 2>&1 && docker image inspect snapcraft-local:8_core22 >/dev/null 2>&1; then
    echo "Using Docker container snapcraft-local:8_core22..."
    docker run --rm -v "${PROJECT_ROOT}:/project" -w /project snapcraft-local:8_core22 pack --destructive-mode
  else
    snapcraft pack --destructive-mode
  fi
  echo ""
  echo "=========================================="
  echo "Test build complete!"
  echo "To install and test locally, run:"
  echo "  sudo snap install --classic --dangerous fnmap_*.snap"
  echo "=========================================="
else
  snapcraft pack
  echo ""
  echo "=========================================="
  echo "Production build complete!"
  echo "To publish to the Snap Store, run:"
  echo "  snapcraft upload --release=stable fnmap_*.snap"
  echo "=========================================="
fi
