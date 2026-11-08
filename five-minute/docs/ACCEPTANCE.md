# Device acceptance gate

Status at initial publication: **not run on a physical iPhone**. Fill observations with the actual OS, build/commit and timestamps; do not replace measurements with expected values.

## Setup and measurements

Use a signed development build on a real iPhone. Record iPhone model, iOS version, Xcode version, commit SHA, timezone and whether other Screen Time rules/Share Across Devices are enabled. Disable overlapping test rules only with the user's agreement; they can otherwise make this app appear to work when its extension did nothing.

Use a second device's stopwatch/screen recording to measure real Instagram foreground sessions. Observe the app's last callback or device Console filtered to the monitor. Avoid collecting screen contents or tokens in logs. Because `includesPastActivity` counts earlier use, use a genuinely fresh daily interval for budget tests. Do not add a production reset button or secretly change the five-minute threshold to speed up testing.

| Case | Steps | Required observation | Actual |
|---|---|---|---|
| Permission denial | Deny access, reopen host | Setup remains incomplete, no claim of active protection | Not run |
| Selection validation | Pick none, a category, two apps; finally Instagram alone | Invalid selection cannot enable; Instagram label visible before enabling | Not run |
| Continuous use | On fresh day, use Instagram continuously for five minutes | Threshold callback and system shield; record actual delay/early delivery | Not run |
| Rapid switching | On fresh day, use repeated ~4.9-second sessions with other apps between | Sessions accumulate instead of resetting; record observed threshold | Not run |
| Host closed | Close/swipe away Five Minute, then exhaust budget | Apple's extension still applies shield | Not run |
| Host reopened | Reopen host repeatedly before/after exhaustion | No new allowance; registration unchanged; current block persists | Not run |
| Already used today | Set up after at least five minutes of earlier Instagram use | Past usage is included; no fresh five-minute allowance | Not run |
| Shield navigation | At block, try app icon, notifications, deep links, app switcher | Instagram remains shielded; Home/Settings/emergency functions accessible | Not run |
| Midnight idle | Exhaust day A, leave phone idle over midnight; open Instagram day B before host | Next interval callback removes old shield without requiring host launch | Not run |
| Midnight foreground | Use Instagram across midnight | New day's allowance works; no unintended permanent shield | Not run |
| Final-second gap | Use near 23:59:59 | Existing shield remains; document unexhausted event gap | Not run |
| Reboot | Reboot before/after exhaustion; unlock and open Instagram before host | Verify monitor restoration and persisted block; record any first-unlock gap | Not run |
| Repair registration | Remove registration through a development-only debugger action; use Repair monitoring | Same daily budget/past use retained, existing exhaustion preserved | Not run |
| Callback ordering | Exercise threshold/interval-start around schedule transition | Current-day exhaustion never cleared by a later interval-start callback | Not run |
| Lock contention | Pause host briefly inside shared-state operation in debugger, trigger threshold | Extension waits then shields; no dropped event or deadlock | Not run |
| Storage failure | In dev build, make test state unreadable/corrupt; reopen host | Visible fault, no deliberate shield clearing, no claim of protection | Not run |
| Authorization recovery | Revoke access in Settings, reopen host, reauthorize and reselect | New token selection requested; prior exhaustion not casually erased | Not run |
| Time manipulation | Change clock/timezone, reboot; restore afterward | Record limits/future-day conservative behavior; do not claim solved | Not run |
| Browser scope | Open instagram.com after native app is shielded | No explicit website shield; measure whether Apple counts web use toward event | Not run |
| Owner bypass | Disable authorization/delete app in a controlled test | Document that individual authorization cannot prevent these actions | Not run |

## Release bar

Compilation and calendar tests must pass first. Continuous use, short sessions, host termination, reopen, reboot and midnight tests must then work on the target iPhone/OS. Any observed early/missing threshold callback blocks a reliability claim until understood. Report actual latency, not "exactly 300.000 seconds". Do not ship if the host says protected while there is no working registration or if routine reopen grants more time.

## Optional system Screen Time layer

The user approved having a trusted person hold the Screen Time passcode. Configure it locally; never put the code in this document. Review Apple's current instructions for the phone's OS: iOS 27 calls its newer controls Time Allowances/Schedules, while earlier versions use App Limits/Downtime. Verify that a limit applies specifically to Instagram and that changing/extending it requires the trusted person's involvement; do not limit all social apps by accident.

Test passcode recovery as a known owner bypass. Do not represent a system passcode as a custom-app entitlement or assume it secures every individual-authorization action.
