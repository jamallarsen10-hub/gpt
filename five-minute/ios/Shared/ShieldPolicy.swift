import Foundation
import ManagedSettings

enum ShieldPolicy {
    /// Call only while holding the shared lock. Never clears another named store.
    @discardableResult
    static func reconcile(_ storage: LockedStore, now: Date = Date()) throws -> Bool {
        guard let configuration = try storage.configuration() else { return false }
        let marker = try storage.exhaustion()
        let blocked = DayPolicy.isBlocked(exhaustedDay: marker?.day,
                                         today: DayPolicy.dayKey(for: now))
        let settings = ManagedSettingsStore(named: Rule.store)
        if blocked {
            settings.shield.applications = configuration.selection.applicationTokens
        } else {
            settings.shield.applications = nil
        }
        return blocked
    }

    static func exhaust(_ storage: LockedStore, now: Date = Date()) throws {
        guard let configuration = try storage.configuration() else {
            throw StoreError.invalidConfiguration
        }
        // Apply a shield even if persisting the marker subsequently fails.
        ManagedSettingsStore(named: Rule.store).shield.applications =
            configuration.selection.applicationTokens
        let previous = try storage.exhaustion()
        // Never shorten a future block after a wall-clock rollback.
        let day = max(previous?.day ?? 0, DayPolicy.dayKey(for: now))
        try storage.saveExhaustion(ExhaustionRecord(day: day, reachedAt: now))
    }
}
