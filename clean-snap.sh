#!/usr/bin/env bash
#
# clean-snap.sh - Clean snapcraft temporary directories and restore build environment
#
# Cleans up temporary snapcraft build directories (parts, stage, prime, .snapcraft)
# and restores the Flutter environment by running:
#   flutter clean && flutter create . --org com.krioltech --project-name fnmap --platforms windows,linux

set -euo pipefail

# Ensure we run from the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_ROOT}"

echo "=========================================="
echo "Cleaning Snapcraft artifacts & restoring environment"
echo "=========================================="

echo "==> Cleaning Snapcraft temporary directories..."
rm -rf parts stage prime .snapcraft

echo "==> Restoring Flutter build environment..."
flutter clean
flutter create . --org com.krioltech --project-name fnmap --platforms windows,linux
flutter pub get
echo ""
echo "=========================================="
echo "Environment successfully restored!"
echo "=========================================="
