"""Portable structure/manifest sanity checks, not an iOS compiler or enforcement test."""
from pathlib import Path
import plistlib
import re

root = Path(__file__).resolve().parents[1]
required = [
    "ios/project.yml", "ios/Config.xcconfig", "ios/FiveMinute/FiveMinuteApp.swift",
    "ios/FiveMinute/LimiterModel.swift", "ios/Monitor/ActivityMonitor.swift",
    "ios/Shared/DayPolicy.swift", "ios/Shared/SharedStore.swift", "ios/Shared/ShieldPolicy.swift",
    "ios/Shared/Rule.swift", "ios/Tests/DayPolicyTests.swift", "HANDOFF.md",
    "docs/ACCEPTANCE.md", "ios/README.md",
]
for name in required:
    assert (root / name).is_file(), f"Missing {name}"
for target, entitlement in [("FiveMinute", "FiveMinute"), ("Monitor", "Monitor")]:
    with (root / "ios" / target / f"{entitlement}.entitlements").open("rb") as f:
        ent = plistlib.load(f)
    assert ent["com.apple.developer.family-controls"] is True
    assert ent["com.apple.security.application-groups"] == ["$(FM_APP_GROUP)"]
    with (root / "ios" / target / "Info.plist").open("rb") as f:
        info = plistlib.load(f)
    assert info["FMAppGroup"] == "$(FM_APP_GROUP)"
    if target == "Monitor":
        assert info["NSExtension"]["NSExtensionPointIdentifier"] == "com.apple.deviceactivity.monitor-extension"
        assert info["NSExtension"]["NSExtensionPrincipalClass"] == "$(PRODUCT_MODULE_NAME).ActivityMonitor"

for source in (root / "ios").rglob("*.swift"):
    text = source.read_text()
    assert not re.search(r"\b(?:TODO|FIXME|fatalError\(\"Not implemented)", text), source
print("Passed portable manifest/source structure checks (not compilation or device validation).")
