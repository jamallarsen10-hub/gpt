#!/bin/bash
set -euo pipefail
TASK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
python3 "$TASK_ROOT/scripts/validate.py"
if command -v swiftc >/dev/null 2>&1; then
    TASK_TMP="$(mktemp -d)"
    trap 'rm -rf "$TASK_TMP"' EXIT
    swiftc "$TASK_ROOT/ios/Shared/DayPolicy.swift" \
        "$TASK_ROOT/ios/Tests/DayPolicyTests.swift" -o "$TASK_TMP/day-policy-tests"
    "$TASK_TMP/day-policy-tests"
else
    echo "SKIPPED Swift policy checks: swiftc is unavailable. Run on the Mac or CI."
fi
