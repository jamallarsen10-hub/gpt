# iPhone build

## Important signing limit

The user has a Mac but no paid Apple Developer membership. A free Xcode Personal Team cannot provision Family Controls. You can generate the project and compile an unsigned simulator build, but that does **not** enable real Screen Time enforcement. A signed device build needs an eligible Apple Developer Program team. Do not remove the entitlement just to make signing appear to pass.

Apple lists individual membership at USD $99/year (check current local pricing); no purchase/enrollment has been made by this project. TestFlight/App Store additionally require Family Controls distribution approval for both app and monitor extension. The development entitlement is distinct from distribution approval.

## Toolchain

- Mac with Xcode 16+ (use an Xcode version that supports the actual iPhone's iOS).
- iPhone running iOS 17.4+ for `includesPastActivity`; screen-time behavior must be tested on the actual OS.
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) 2.42+; install from Homebrew if needed: `brew install xcodegen`.
- No third-party runtime libraries.

From the `five-minute` folder:

```bash
bash scripts/build-macos.sh
```

This validates manifests, runs calendar-policy checks, generates `ios/FiveMinute.xcodeproj`, and compiles the host and embedded extension against the simulator SDK without signing. Simulator compilation checks Swift/API wiring; it does not validate authorization or shielding.

## Signed physical-device build (after eligible team access)

1. In `ios/`, create a git-ignored `Signing.local.xcconfig`:

   ```xcconfig
   DEVELOPMENT_TEAM = YOUR_TEAM_ID
   FM_BUNDLE_PREFIX = your.unique.reverse.domain
   FM_APP_GROUP = group.your.unique.reverse.domain.fiveminute
   ```

2. Run `xcodegen generate` in `ios/`, then open `FiveMinute.xcodeproj`.
3. In Signing & Capabilities, use the same eligible team for **FiveMinute** and **Monitor**. Confirm Family Controls (development) and the **same App Group** exist on both App IDs and provisioning profiles. The extension identifier must begin with the host identifier.
4. Connect the iPhone, enable Developer Mode if Xcode requests it, select it as the destination, and run the FiveMinute scheme. No secret, certificate, passcode or profile belongs in GitHub.
5. Authorize individual Screen Time access, select Instagram alone in the picker, verify the displayed app label, and enable the daily limit.
6. Execute every required case in `../docs/ACCEPTANCE.md`. A build is not a passed device test.

If Xcode reports `Personal development teams do not support the Family Controls (Development) capability`, that is an account limitation, not a missing line of Swift. If the App Group container is unavailable, check both targets' entitlements and signed profiles first.

## Trusted person / system passcode

The trusted person controls Apple's **Screen Time passcode**, not the iPhone unlock passcode and not a code invented by this app. This custom app has no override button. It uses `.individual` authorization for the adult device owner; another adult is not silently treated as a Family Sharing child's guardian.

Configure any system passcode directly on the iPhone. Do not share it with an AI or commit it. A passcode does not guarantee that revocation/deletion/recovery is impossible. Review the recovery flow with the trusted person and test changes to settings instead of assuming they are locked.

## Daily semantics and failure handling

Apple owns usage accumulation. The event threshold is five minutes, not a five-minute monitoring schedule. Includes-past-activity is enabled; a person who already used Instagram five minutes today may be blocked immediately after setup.

The rule includes one application token and no explicit categories/web domains. Only `shield.applications` is set. Apple may implicitly include associated website use in an application's DeviceActivity event; exact app-only measurement cannot be guaranteed with this API. No websites are intentionally shielded.

A saved current-day/future-day exhaustion marker is reapplied on app foreground. Registered monitoring is not restarted on every app launch. If permission is observed lost, the selection is marked for renewal; new tokens must be selected after reauthorization. Revocation while the host never runs can still be an owner bypass, so do not promise token recovery without testing it.

The file lock serializes short state/shield operations. `startMonitoring` runs outside that lock because it can trigger extension callbacks. No requests for authorization, network work, timers or user interaction run inside the lock. Corrupt/inaccessible state is reported; existing shields are not cleared in an error handler. Losing the selection itself prevents reconstructing the opaque token and is an explicit device-test failure case.
