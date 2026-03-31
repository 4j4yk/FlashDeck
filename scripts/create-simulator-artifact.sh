#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/FlashCards.xcodeproj"
DERIVED_DATA_PATH="$ROOT_DIR/.derivedData-simulator-release"
RELEASE_DIR="$ROOT_DIR/release"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/FlashCards.app"
ZIP_PATH="$RELEASE_DIR/FlashCards-simulator.app.zip"

mkdir -p "$RELEASE_DIR"

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme FlashCards \
  -configuration Debug \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -destination 'platform=iOS Simulator,OS=latest,name=iPhone 16 Pro' \
  build

ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

echo "Created:"
echo "  $ZIP_PATH"
