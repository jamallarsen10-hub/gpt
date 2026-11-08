# Sources checked 2026-11-08

Prefer official API docs over snippets from memory. These support the design; baseline source is original, not copied.

## Apple

- [DeviceActivityEvent initializer, includesPastActivity](https://developer.apple.com/documentation/deviceactivity/deviceactivityevent/init(applications:categories:webdomains:threshold:includespastactivity:)) — OS counts usage in the scheduled interval; no hard real-time delivery guarantee stated.
- [Minimum monitoring interval](https://developer.apple.com/documentation/deviceactivity/deviceactivitycenter/monitoringerror/intervaltooshort) — 15-minute schedule minimum, independently of a five-minute event threshold.
- [FamilyActivitySelection](https://developer.apple.com/documentation/familycontrols/familyactivityselection) — opaque application/category/web-domain tokens; tokens invalidated when authorization is revoked.
- [FamilyActivityPicker](https://developer.apple.com/documentation/familycontrols/familyactivitypicker) — user selects apps; no hardcoded token for Instagram.
- [DeviceActivityMonitor](https://developer.apple.com/documentation/deviceactivity/deviceactivitymonitor) — extension callbacks for schedules and thresholds.
- [ManagedSettingsStore](https://developer.apple.com/documentation/managedsettings/managedsettingsstore) — system shielding and shared named stores.
- [Configuring Family Controls](https://developer.apple.com/documentation/xcode/configuring-family-controls) — entitlement/capability and profiles on host/extension.
- [Distribution entitlement requests](https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement) — separate approval for app and Screen Time extension targets.
- [WWDC22 Screen Time APIs](https://developer.apple.com/videos/play/wwdc2022/110336/) — individual authorization differs from parental controls.

## Open-source references supplied by user

- [ScreenBreak](https://github.com/christianp-622/ScreenBreak) — Swift framework/extension architecture. Broader scope than this MVP; do not copy its analytics/widgets.
- [react-native-device-activity](https://github.com/kingstinct/react-native-device-activity) — native Screen Time bridging reference. No React Native dependency in V1.
- [SelfLock](https://github.com/EtashTyagi/SelfLock), [nudge](https://github.com/astraedus/nudge), [cst](https://github.com/childscreentime/cst) — existence verified, Android-only and excluded after scope clarification.

## Corrections to the original brief

No app-side monotonic timer can observe another app's iOS foreground stream. No guarantee of exactly 300.000 seconds, undismissable by owner, clock-cheat immunity or a universal extension memory limit is asserted. Encrypted storage cannot prevent uninstall/reinstallation. Distribution entitlement and physical-device tests are deployment work, not tasks an AI can bypass.
