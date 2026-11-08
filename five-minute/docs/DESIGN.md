# Design decisions

## Smallest useful product

One iPhone, one daily rule, one app, one screen. Setup is authorization → selection → enable. Once enabled, selection is locked in the UI. No extra-time or reset control. Settings and emergency paths remain accessible.

| Decision | V1 behavior | Reason |
|---|---|---|
| Platform | Native Swift / iPhone only | User only needs Instagram on their iPhone |
| Budget | 300 seconds daily | Fixed requirement; no configuration to casually override |
| Identity | One opaque application token | Standard APIs do not derive Instagram’s token from its bundle ID |
| Tracking | DeviceActivityEvent, includesPastActivity | Apple counts across sessions even when host is closed |
| Schedule | Midnight to 23:59:59, repeating | Schedule must be >=15 minutes; threshold is separately five minutes |
| Enforcement | Default system ManagedSettings shield | No custom shield/action target needed to prove blocking |
| Persistence | Atomic App Group files + process lock + iOS data protection | Host/extension share state without a backend or custom cryptography |
| Status | Authorization, registration, last exhaustion | No app-side access to an exact live usage counter |
| First day | Include earlier activity in the daily schedule | Re-enabling must not silently grant a fresh five minutes |

## State and event path

Host requests individual FamilyControls authorization. It validates exactly one application token and no categories/domains, saves immutable selection, then registers a daily activity with one five-minute event. A failed registration is visible and retryable. A working monitor is not restarted on every launch.

The extension records exhaustion and sets a named ManagedSettingsStore shield. At interval start, a marker for today or a future day keeps the shield; an older marker permits clearing. Do not clear at interval end: an existing block lasts through the final second until the next interval starts. Host foreground reconciles missing registration and re-applies a current saved block. A shared file lock serializes marker/shield operations between the processes.

Selection/configuration and exhaustion live in separate atomic files. Missing/corrupt state reports a fault; the app leaves existing shields intact. It cannot reconstruct an opaque token if the selection is lost. No app-side CACurrentMediaTime counter: it cannot observe Instagram foreground use. No extensions for analytics, customized shields, widgets or background tasks.

## Confirmed deployment choices

User has a Mac, no paid developer account, wants the Instagram native app only, and agrees that a trusted person can hold the system Screen Time passcode. Baseline uses individual authorization on the adult user's own iPhone. It does not implement an in-app override passcode. System settings are configured separately and the app cannot set Apple's passcode.

A free Personal Team cannot provision Family Controls (development), so a paid/eligible developer team is a device-build dependency. Unsigned simulator compilation can proceed without it. No enrollment or purchase is authorized or performed here. A Family Sharing child or supervised/MDM deployment is a different model; do not change the adult's account type to make an API work.

## Known limits

- Users can revoke individual authorization/delete/reinstall. No local storage mechanism prevents that.
- System callbacks can be delayed or OS-version dependent. Measure actual shield behavior on device.
- Day reset follows the system calendar. Date/time/timezone manipulation is not solved. Future-day exhaustion markers remain blocked conservatively.
- The schedule has a final-second gap. Existing shields stay in place; unexhausted use during that second is outside the event schedule.
- App selection is opaque: exactly one token is enforced, but the person must choose Instagram.
- Instagram in a browser and other devices are not covered by the native-app selection.
- Apple may implicitly count an associated website in the application activity event, even though this app configures no website shields. App-only shielding is deliberate; app-only measurement is not guaranteed.
- Data protection can delay file access until first unlock following a reboot.

## Gate before adding features

Compile/sign on macOS and run the real-iPhone acceptance script. Record callback timing and observed shield delay. Fix enforcement failures before adding any features.
