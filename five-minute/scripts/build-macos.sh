#!/bin/bash
set -euo pipefail
TASK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "A Mac with Xcode is required for the iOS SDK build." >&2
    exit 1
fi
command -v xcodegen >/dev/null || { echo "Install XcodeGen first: brew install xcodegen" >&2; exit 1; }
bash "$TASK_ROOT/scripts/check.sh"
cd "$TASK_ROOT/ios"
xcodegen generate
xcodebuild -project FiveMinute.xcodeproj -scheme FiveMinute \
    -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build
echo "Unsigned simulator SDK build finished. Screen Time enforcement still requires a signed physical-device test."
