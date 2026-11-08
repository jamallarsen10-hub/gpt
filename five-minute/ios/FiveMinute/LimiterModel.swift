import Combine
import DeviceActivity
import FamilyControls
import Foundation

@MainActor
final class LimiterModel: ObservableObject {
    @Published var selection = FamilyActivitySelection(includeEntireCategory: false)
    @Published private(set) var authorized = false
    @Published private(set) var selectionLocked = false
    @Published private(set) var registered = false
    @Published private(set) var blocked = false
    @Published private(set) var busy = false
    @Published private(set) var error: String?
    @Published private(set) var diagnostic: MonitorDiagnostic?

    private let center = DeviceActivityCenter()

    var validSelection: Bool {
        selection.applicationTokens.count == 1 &&
        selection.categoryTokens.isEmpty && selection.webDomainTokens.isEmpty
    }

    var status: String {
        if !authorized { return "Screen Time permission needed" }
        if error != nil { return "Protection needs attention" }
        if blocked { return "Daily limit reached" }
        if registered { return "Daily limit is active" }
        return "Finish setup"
    }

    func requestAccess() async {
        guard !busy else { return }
        busy = true
        error = nil
        do {
            // Revocation invalidates existing tokens. Record it before asking again.
            if AuthorizationCenter.shared.authorizationStatus != .approved {
                try SharedStore.withLock { storage in
                    if try storage.configuration() != nil { try storage.markAuthorizationLost() }
                }
            }
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            refresh()
        } catch {
            self.error = error.localizedDescription
        }
        busy = false
    }

    func refresh() {
        authorized = AuthorizationCenter.shared.authorizationStatus == .approved
        error = nil
        do {
            try SharedStore.withLock { storage in
                let configuration = try storage.configuration()
                if !authorized, configuration != nil { try storage.markAuthorizationLost() }
                let renewal = try storage.needsNewSelection()
                selectionLocked = configuration != nil && !renewal
                if let configuration, selectionLocked { selection = configuration.selection }
                registered = authorized && selectionLocked && center.activities.contains(Rule.activity)
                if authorized, selectionLocked {
                    blocked = try ShieldPolicy.reconcile(storage)
                } else {
                    blocked = false
                }
                diagnostic = try storage.diagnostic()
                if let failure = diagnostic?.error { error = "Monitor: \(failure)" }
            }
        } catch {
            registered = false
            self.error = error.localizedDescription
        }
    }

    func enable() {
        guard !busy, authorized else { return }
        busy = true
        error = nil
        do {
            let prepared = try SharedStore.withLock { storage -> (SelectionRecord, Bool) in
                let saved = try storage.configuration()
                let renewing = try storage.needsNewSelection()
                let configuration: SelectionRecord
                if let saved, !renewing {
                    configuration = saved
                } else {
                    configuration = try SelectionRecord(selection: selection)
                    try storage.saveConfiguration(configuration)
                }
                return (configuration, renewing)
            }
            // Registration can trigger extension callbacks. Never hold the shared lock here.
            // A successful registration must not restart on ordinary app launches/taps.
            if prepared.1 || !center.activities.contains(Rule.activity) {
                let event = DeviceActivityEvent(
                    applications: prepared.0.selection.applicationTokens,
                    threshold: DateComponents(second: DayPolicy.budgetSeconds),
                    includesPastActivity: true
                )
                try center.startMonitoring(Rule.activity, during: Rule.schedule,
                                           events: [Rule.event: event])
            }
            try SharedStore.withLock { storage in
                try storage.markSelectionRenewed()
                _ = try ShieldPolicy.reconcile(storage)
            }
            refresh()
        } catch {
            // A saved selection may already be committed even if registration failed.
            // Reflect that fixed selection before showing the retryable error.
            refresh()
            self.error = error.localizedDescription
        }
        busy = false
    }
}
