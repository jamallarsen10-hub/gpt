# Five Minute — iPhone

A lean native iPhone app: five cumulative minutes of Instagram per day, then Apple’s system shield until the next day. **Baseline, not yet device-validated or tamper-proof.**

## V1 contract

1. Explicitly authorize Screen Time access.
2. Select exactly one app in Apple’s picker; choose Instagram.
3. Apple counts a daily 300-second usage budget across sessions.
4. Shield the selected app until the next day. No snooze, extra time, or in-app reset.
5. Show permission/monitoring health and errors, without inventing an exact live countdown.

Confirmed setup: Mac available, no paid developer account, trusted person can hold a system Screen Time passcode. **Free Personal Teams cannot provision Family Controls.** Source and an unsigned SDK build can be prepared now; a signed device test needs eligible developer-team access. No purchase has been made.

iPhone only. No Android, accounts, backend, analytics, React Native bridge or custom shield extensions.

**Verified:** app and embedded monitor compile with Xcode 16.4 against the iOS 18.5 simulator SDK; all 12 calendar-policy checks pass. [Build evidence](https://github.com/jamallarsen10-hub/gpt/actions/runs/42527210629). Signed real-iPhone authorization and shielding remain untested.

## Start here

- [Product decisions and architecture](docs/DESIGN.md)
- [Build and signing](ios/README.md)
- [Device acceptance tests](docs/ACCEPTANCE.md)
- [Claude / next-agent handoff](HANDOFF.md)
- [Verified sources and corrections](docs/REFERENCES.md)

## Enforcement limits

An ordinary self-installed app cannot be un-bypassable. Apple’s individual authorization permits revocation and app deletion. A trusted-person Screen Time setup is separate from this app and can add friction; parental/supervised deployment is a different model. OS counting and callback delivery are not a millisecond or hard real-time guarantee. No website shield is configured, although Apple may count associated website use in the application usage event. Other devices and reinstall are outside the rule.

## Folder structure

```text
five-minute/
  ios/
    FiveMinute/   SwiftUI setup and status
    Monitor/      DeviceActivityMonitor extension
    Shared/       policy, persistence, shield names
    Tests/        day-boundary and policy checks
    project.yml   reproducible XcodeGen target configuration
  scripts/        portable checks and macOS build entry point
  docs/           product contract, sources, device test gates
  HANDOFF.md      status and exact next actions
  CLAUDE.md       Claude Code entry point
  AGENTS.md       engineering and checkpoint instructions
```

Source in this folder is original implementation. Reference projects are linked, not vendored. The MIT license applies only to this folder.
