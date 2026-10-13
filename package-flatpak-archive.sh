#!/usr/bin/env bash
#
# package-flatpak-archive.sh - Package fnmap into a release archive for Flathub
#
# Implements Step 5 of flathub-upgrade-instructions.md:
# Assembles the Flutter Linux release bundle, AppStream metadata, desktop
# launcher, and icon into the 'fnmap-archive/' structure expected by Flathub,
# compresses it into 'fnmap-<version>.x64.tar.gz', and computes the SHA-256 hash.
#
# Usage:
#   ./package-flatpak-archive.sh [options]
#
# Options:
#   -b, --build          Rebuild Flutter Linux release bundle before packaging
#   -c, --clean          Run 'flutter clean' and 'flutter pub get' prior to building
#   -v, --version <ver>  Override archive version string (default: auto-detected from pubspec.yaml)
#   -o, --output <dir>   Output directory for the archive (default: project root)
#   -h, --help           Show this help message
#

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_ROOT}"

# Default options
DO_BUILD=false
DO_CLEAN=false
CUSTOM_VERSION=""
OUTPUT_DIR="${PROJECT_ROOT}"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--build)
      DO_BUILD=true
      shift
      ;;
    -c|--clean)
      DO_CLEAN=true
      DO_BUILD=true
      shift
      ;;
    -v|--version)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --version requires a version argument (e.g. 1.4.0-1)" >&2
        exit 1
      fi
      CUSTOM_VERSION="$2"
      shift 2
      ;;
    -o|--output)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --output requires a directory argument" >&2
        exit 1
      fi
      OUTPUT_DIR="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  -b, --build          Build Flutter Linux release bundle before packaging"
      echo "  -c, --clean          Run 'flutter clean' and 'flutter pub get' before building"
      echo "  -v, --version <ver>  Specify archive version string (default: from pubspec.yaml)"
      echo "  -o, --output <dir>   Destination directory for the archive (default: project root)"
      echo "  -h, --help           Show this help message"
      exit 0
      ;;
    *)
      echo "Error: Unknown argument '$1'" >&2
      echo "Run '$0 --help' for usage." >&2
      exit 1
      ;;
  esac
done

# Resolve version
if [[ -n "${CUSTOM_VERSION}" ]]; then
  VERSION="${CUSTOM_VERSION}"
else
  if [[ ! -f "pubspec.yaml" ]]; then
    echo "Error: pubspec.yaml not found in ${PROJECT_ROOT}" >&2
    exit 1
  fi
  # Convert "1.4.0+1" into "1.4.0-1"
  VERSION="$(grep '^version:' pubspec.yaml | head -n 1 | awk '{print $2}' | tr '+' '-')"
  if [[ -z "${VERSION}" ]]; then
    echo "Error: Failed to auto-detect version from pubspec.yaml" >&2
    exit 1
  fi
fi

ARCHIVE_NAME="fnmap-${VERSION}.x64.tar.gz"
OUTPUT_PATH="${OUTPUT_DIR}/${ARCHIVE_NAME}"
BUNDLE_DIR="${PROJECT_ROOT}/build/linux/x64/release/bundle"

echo "=========================================="
echo "Packaging Flathub Archive: ${ARCHIVE_NAME}"
echo "=========================================="

# Build release bundle if requested or if bundle does not exist
if [[ "${DO_BUILD}" == "true" ]] || [[ ! -d "${BUNDLE_DIR}" ]]; then
  if [[ "${DO_CLEAN}" == "true" ]]; then
    echo "==> [1/4] Cleaning Flutter workspace..."
    flutter clean
    flutter pub get
  fi

  echo "==> [2/4] Building Flutter Linux release bundle..."
  flutter build linux --release
else
  echo "==> Using existing Flutter release bundle (${BUNDLE_DIR})"
fi

# Verify required input assets exist
if [[ ! -f "${BUNDLE_DIR}/fnmap" ]]; then
  echo "Error: Release executable not found at ${BUNDLE_DIR}/fnmap" >&2
  exit 1
fi

if [[ ! -f "flatpak/com.krioltech.fnmap.metainfo.xml" ]]; then
  echo "Error: AppStream metainfo not found at flatpak/com.krioltech.fnmap.metainfo.xml" >&2
  exit 1
fi

if [[ ! -f "flatpak/com.krioltech.fnmap.desktop" ]]; then
  echo "Error: Desktop file not found at flatpak/com.krioltech.fnmap.desktop" >&2
  exit 1
fi

if [[ ! -f "assets/fnmap.png" ]]; then
  echo "Error: Icon asset not found at assets/fnmap.png" >&2
  exit 1
fi

# Create staging directory
STAGE_ROOT="$(mktemp -d /tmp/fnmap-archive-staging.XXXXXX)"
ARCHIVE_STAGE="${STAGE_ROOT}/fnmap-archive"

cleanup() {
  rm -rf "${STAGE_ROOT}"
}
trap cleanup EXIT

echo "==> [3/4] Staging archive structure..."
mkdir -p "${ARCHIVE_STAGE}/bin" "${ARCHIVE_STAGE}/icons"

# Copy bundle
cp -r "${BUNDLE_DIR}" "${ARCHIVE_STAGE}/bin/"
chmod +x "${ARCHIVE_STAGE}/bin/bundle/fnmap"

# Copy AppStream metainfo
cp "flatpak/com.krioltech.fnmap.metainfo.xml" "${ARCHIVE_STAGE}/"

# Copy desktop launcher (Flathub manifest expects fnmap.desktop)
cp "flatpak/com.krioltech.fnmap.desktop" "${ARCHIVE_STAGE}/fnmap.desktop"

# Copy app icon
cp "assets/fnmap.png" "${ARCHIVE_STAGE}/icons/fnmap.png"

# Ensure target output directory exists
mkdir -p "${OUTPUT_DIR}"

echo "==> [4/4] Creating tar.gz archive..."
tar -czf "${OUTPUT_PATH}" -C "${STAGE_ROOT}" fnmap-archive

# Verify archive creation
if [[ ! -f "${OUTPUT_PATH}" ]]; then
  echo "Error: Failed to create archive at ${OUTPUT_PATH}" >&2
  exit 1
fi

ARCHIVE_SIZE="$(du -h "${OUTPUT_PATH}" | awk '{print $1}')"
SHA256="$(sha256sum "${OUTPUT_PATH}" | awk '{print $1}')"

echo ""
echo "=========================================="
echo "Archive Created Successfully!"
echo "=========================================="
echo "File:     ${OUTPUT_PATH}"
echo "Size:     ${ARCHIVE_SIZE}"
echo "Version:  ${VERSION}"
echo "SHA-256:  ${SHA256}"
echo "=========================================="
echo ""
echo "Next Steps for Flathub Release:"
echo ""
echo "1. Copy the archive to your fnmap-flatpak repository:"
echo "   cp \"${OUTPUT_PATH}\" /path/to/fnmap-flatpak/archives/"
echo "   cd /path/to/fnmap-flatpak"
echo "   git add archives/${ARCHIVE_NAME}"
echo "   git commit -m \"Add fnmap ${VERSION} release archive\""
echo "   git push origin main"
echo "   git tag v${VERSION}"
echo "   git push origin v${VERSION}"
echo ""
echo "2. Update com.krioltech.fnmap.yml in flathub/com.krioltech.fnmap with:"
echo ""
cat <<EOF
      - type: archive
        url: https://github.com/gmckesey/fnmap-flatpak/raw/refs/tags/v${VERSION}/archives/${ARCHIVE_NAME}
        sha256: ${SHA256}
        dest: fnmap-archive
EOF
echo ""
