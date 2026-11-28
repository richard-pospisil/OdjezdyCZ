#!/bin/zsh
# Build a universal (Apple silicon + Intel) Release of Odjezdy and zip it for sharing.
# Output: dist/Odjezdy.zip (this is what goes into a GitHub release).
# Optional: DEVELOPMENT_TEAM=<your team id> scripts/package.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# -file-prefix-map and stripping (DEPLOYMENT_POSTPROCESSING) keep this folder's path, which
# contains your user name, out of the binary.
xcodebuild -project Odjezdy.xcodeproj -scheme Odjezdy -configuration Release \
  -destination 'generic/platform=macOS' \
  -derivedDataPath build/xcode -allowProvisioningUpdates \
  OTHER_SWIFT_FLAGS="-file-prefix-map $PWD=. -file-prefix-map ${PWD#/private}=." DEPLOYMENT_POSTPROCESSING=YES \
  ${DEVELOPMENT_TEAM:+DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM} build | grep -E "error|BUILD" || true
APP=build/xcode/Build/Products/Release/Odjezdy.app
[[ -d "$APP" ]] || { echo "Build failed"; exit 1; }
echo "Architectures: $(lipo -archs "$APP/Contents/MacOS/Odjezdy")"
mkdir -p dist
rm -f dist/Odjezdy.zip
ditto -c -k --keepParent "$APP" dist/Odjezdy.zip
echo "Created dist/Odjezdy.zip ($(du -h dist/Odjezdy.zip | cut -f1))"
