import DeviceActivity
import Foundation
import OSLog

final class ActivityMonitor: DeviceActivityMonitor {
    private let log = Logger(subsystem: "dev.fiveminute", category: "monitor")

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        guard activity == Rule.activity else { return }
        record("intervalStarted") { storage in
            _ = try ShieldPolicy.reconcile(storage)
        }
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name,
                                        activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        guard activity == Rule.activity, event == Rule.event else { return }
        record("thresholdReached") { storage in
            try ShieldPolicy.exhaust(storage)
        }
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        guard activity == Rule.activity else { return }
        // Keep any shield through the end-of-day schedule gap.
        record("intervalEnded") { _ in }
    }

    private func record(_ callback: String, operation: (LockedStore) throws -> Void) {
        do {
            try SharedStore.withLock { storage in
                try operation(storage)
                try storage.saveDiagnostic(MonitorDiagnostic(callback: callback,
                                                            recordedAt: Date(), error: nil))
            }
        } catch {
            // Never clear a shield or dump app tokens in an error path.
            log.error("Screen Time callback failed; check signing, storage and app diagnostics.")
            let message = error.localizedDescription
            try? SharedStore.withLock { storage in
                try storage.saveDiagnostic(MonitorDiagnostic(callback: callback,
                                                            recordedAt: Date(), error: message))
            }
        }
    }
}
