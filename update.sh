#!/usr/bin/env bash
# Update script for rustdesk package
# Usage: ./update.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NIX="$SCRIPT_DIR/package.nix"

# Get current version from package.nix
CURRENT_VERSION=$(grep 'version = ' "$PACKAGE_NIX" | head -1 | sed 's/.*"\(.*\)".*/\1/')
echo "Current version: $CURRENT_VERSION"

# Get latest version from GitHub API
echo "Checking latest version..."
LATEST_VERSION=$(curl -sL "https://api.github.com/repos/rustdesk/rustdesk/releases/latest" | jq -r '.tag_name')

if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
    echo "Error: Could not determine latest version from GitHub"
    exit 1
fi

echo "Latest version: $LATEST_VERSION"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "Already up to date!"
    exit 0
fi

# Construct download URL
DOWNLOAD_URL="https://github.com/rustdesk/rustdesk/releases/download/${LATEST_VERSION}/rustdesk-${LATEST_VERSION}-x86_64.deb"

# Fetch new hash
echo "Fetching hash for $LATEST_VERSION..."
NEW_HASH=$(nix-prefetch-url "$DOWNLOAD_URL" 2>&1 | tail -1)
SRI_HASH=$(nix hash convert --to sri --hash-algo sha256 "$NEW_HASH")

echo "New SRI hash: $SRI_HASH"

# Update package.nix - version
sed -i "s/version = \"$CURRENT_VERSION\"/version = \"$LATEST_VERSION\"/" "$PACKAGE_NIX"

# Update package.nix - hash
sed -i "s|hash = \"sha256-.*\"|hash = \"$SRI_HASH\"|" "$PACKAGE_NIX"

echo "Updated package.nix to version $LATEST_VERSION"
echo ""
echo "Don't forget to rebuild: ./install.sh"
