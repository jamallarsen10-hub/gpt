# Handoff — 2026-11-08

## User goal and latest scope

Build an open-source five-minute daily Instagram limiter, publish code to GitHub so Claude can contribute, and leave durable handoffs before context/quota boundaries. User clarified: **Apple/iPhone only** and **lean design first, prove enforcement before extra features**.

## Current checkpoint

Design/contract and engineering instructions written. Native source implementation has not started. No app is installed, compiled or device-tested yet. The Android design was removed immediately after the iPhone-only clarification.

Repository: `jamallarsen10-hub/gpt`, dedicated branch `codex/five-minute-limiter`, isolated `five-minute/` folder. Root files are an unrelated existing project; preserve them. Connected GitHub tools can publish files/branches but do not expose repository creation. Browser repository creation requires sign-in. Use the connected branch rather than blocking on login. A standalone repository can be made later if wanted.

## Clarifications pending

User explicitly invited questions. Ask whether a trusted person can hold an override passcode, what Mac/Apple Developer access exists, and whether Instagram web should also be blocked. These affect enforcement/deployment but do not require Android or a backend.

## Next actions

1. Read user answers and DESIGN.md. Surface the simpler built-in Screen Time + trusted-person passcode option if it meets the goal.
2. Implement native SwiftUI host + one DeviceActivityMonitor extension using FamilyControls and ManagedSettings. iOS 17.4+ permits includesPastActivity. Exactly one selected application token; no categories.
3. Include App Group atomic persistence and shared process locking; no in-app time reset or monitor restart on ordinary launches.
4. Add XcodeGen project.yml, Info.plist/entitlements, error/status UI, policy checks and real-device acceptance plan.
5. Compile on macOS if available (this runtime is Linux with Java, no Xcode or Swift). Do not label unrun compilation/device checks passed. A macOS GitHub Actions check may be useful if workflow writes are permitted.
6. Publish coherent source and updated handoff using GitHub tree/commit/ref tools, then open a reviewable draft PR and give user Claude entry links.

## Verification so far

- Verified repository permissions and branch creation via GitHub connector.
- Inspected official Apple docs for DeviceActivityEvent, minimum 15-minute schedule, FamilyActivitySelection opaque tokens, Family Controls development/distribution entitlements.
- Verified user-provided public reference repositories exist. Have not copied code or relied on their implementation details.
- No tests/builds run. A Gradle download was initiated before the scope changed; ignore `/tmp/fiveminute-tools` and do not revive Android work.

## Nonnegotiable technical corrections

- Individual authorization allows revocation/deletion. Do not promise un-bypassable.
- iOS counts usage in the OS; CACurrentMediaTime cannot track another app while this host is suspended.
- Select opaque token via FamilyActivityPicker; do not fabricate Instagram bundle-ID-to-token conversion.
- DeviceActivity daily schedule is distinct from its five-minute usage threshold.
- Apple callback latency and current OS behavior require physical-device validation.
- Apple signing/App Groups and Family Controls capability are required for host and extension; distribution approval is needed for TestFlight/App Store.

Update this file at each coherent milestone. Account usage quota is not visible here, so checkpoint proactively.
