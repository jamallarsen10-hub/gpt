# Handoff — 2026-11-08

## Confirmed goal

Native iPhone-only focus app: 300 cumulative seconds daily, choose Instagram, then Apple system shield until the next day. Only the native app should be shielded. No Android, backend, analytics, widgets or custom shield/action extensions. User has a Mac, no paid Apple Developer account, and accepts having a trusted person hold the system Screen Time passcode. Build lean and prove enforcement before expanding.

## Current implementation checkpoint

Native source is complete as a baseline: SwiftUI setup/status, individual FamilyControls authorization, validation of one application token, fixed daily DeviceActivity schedule/event with includesPastActivity, named ManagedSettings shield, atomic data-protected App Group files, process lock, persisted exhaustion, permission-loss selection renewal, retryable registration, and callback diagnostics. Both targets have explicit Info.plist and entitlements. XcodeGen project, build scripts, 12 calendar-policy checks and physical-device acceptance checklist are included.

Repository: `jamallarsen10-hub/gpt`, branch `codex/five-minute-limiter`, folder `five-minute/`. Root JavaScript files are an unrelated existing project: preserve them. GitHub connector does not expose repository creation; this isolated branch avoids a browser sign-in blocker. `.github/workflows/five-minute.yml` adds a macOS unsigned SDK build plus policy checks for this folder.

## Verification

- Portable manifest/source structure check passed with `bash five-minute/scripts/check.sh` in Linux.
- Python validator syntax check passed.
- Swift policy tests were SKIPPED locally: Linux runtime has no swiftc. macOS CI ran and PASSED all 12 policy checks using Xcode 16.4.
- First macOS SDK build run 42527027717 caught a missing Foundation import in Shared/Rule.swift. Fixed in this checkpoint; SDK rebuild pending. Check the latest run before reporting compilation passed.
- Signed physical-device authorization/shielding NOT RUN. No installation or developer enrollment performed.

## Immediate next steps

1. Inspect GitHub Actions for the branch/PR. Fix any actual compiler/generation errors and update this handoff with results. Use `bash scripts/build-macos.sh` from five-minute on a Mac.
2. Get eligible developer-team access before signed device work. A free Xcode Personal Team does not support Family Controls (development). Apple lists standard membership at USD $99/year. Do not purchase or remove required entitlements to pretend it works.
3. Set unique bundle prefix/App Group/team in git-ignored `ios/Signing.local.xcconfig`; register Family Controls and identical App Group for host/extension. See ios/README.md.
4. Test on the actual iPhone OS using docs/ACCEPTANCE.md: continuous/4.9-second sessions, host termination/reopen, reboot, midnight, callback ordering, lock contention, permission recovery. Record actual delay.
5. User/trusted person can configure Apple's own Screen Time passcode directly on iPhone as a separate commitment layer. Do not create an in-app PIN or ask to see the system PIN. iOS 27 uses newer Time Allowances/Passcode & Management terminology: verify current settings before instructions.

## Important limits

- The app uses individual authorization on an adult's own iPhone. A trusted person holding a system passcode does not transform this into child/MDM authorization or guarantee revocation/deletion resistance.
- No app-side monotonic timer can observe another app's iOS foreground activity. Apple counts use and delivers callbacks, without a hard real-time guarantee.
- One opaque token is enforced, but the user must choose Instagram. No fabricated bundle-ID-to-token conversion.
- Schedule is daily midnight–23:59:59 (>=15 minutes); threshold is separately 300 seconds. An existing shield is not cleared at interval end; final-second unexhausted monitoring gap is documented.
- No explicit web-domain shield is configured. Apple may include associated website use in an application's activity event; perfectly app-only measurement cannot be guaranteed.
- Existing shields remain on storage errors. Lost/corrupt selection cannot reconstruct opaque tokens. A file lock serializes short operations; startMonitoring/authorization never run under it. Device tests must cover contention and callback ordering.
- Permission loss observed by the host requires new token selection after reauthorization. Revocation while the host never runs is a remaining owner bypass.
- Clock/timezone manipulation, reinstall, other devices and Apple OS regressions are not solved.

## Checkpoint discipline

Update HANDOFF.md before context/quota boundaries and push a coherent commit. Agents cannot reliably inspect remaining account quota, so checkpoint by milestones. Never label unrun SDK/device checks passed. No personal usage records, tokens, keys, provisioning profiles or passcodes in GitHub.
