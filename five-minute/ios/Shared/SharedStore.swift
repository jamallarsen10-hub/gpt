import Darwin
import FamilyControls
import Foundation

struct SelectionRecord: Codable {
    let schema: Int
    let selection: FamilyActivitySelection
    let savedAt: Date

    init(selection: FamilyActivitySelection) throws {
        guard selection.applicationTokens.count == 1,
              selection.categoryTokens.isEmpty,
              selection.webDomainTokens.isEmpty else { throw StoreError.selectOneApp }
        schema = 1
        self.selection = selection
        savedAt = Date()
    }

    func validate() throws {
        guard schema == 1,
              selection.applicationTokens.count == 1,
              selection.categoryTokens.isEmpty,
              selection.webDomainTokens.isEmpty else { throw StoreError.invalidConfiguration }
    }
}

struct ExhaustionRecord: Codable {
    let day: Int
    let reachedAt: Date
}

struct MonitorDiagnostic: Codable {
    let callback: String
    let recordedAt: Date
    let error: String?
}

enum StoreError: LocalizedError {
    case missingAppGroup, lockUnavailable, selectOneApp, invalidConfiguration

    var errorDescription: String? {
        switch self {
        case .missingAppGroup:
            return "Shared storage is unavailable. Check App Group signing on both targets."
        case .lockUnavailable:
            return "Shared storage is busy or unavailable. Unlock the phone and try again."
        case .selectOneApp:
            return "Select Instagram alone. Do not select a whole category or website."
        case .invalidConfiguration:
            return "The saved app selection is invalid. Existing shields have been left in place."
        }
    }
}

/// All reads/writes and shield reconciliation must happen inside withLock.
/// No UserDefaults cache is shared between the host process and extension.
struct SharedStore {
    static func withLock<T>(_ operation: (LockedStore) throws -> T) throws -> T {
        guard let group = Bundle.main.object(forInfoDictionaryKey: "FMAppGroup") as? String,
              !group.contains("$("),
              let root = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: group
              ) else { throw StoreError.missingAppGroup }

        let folder = root.appendingPathComponent("FiveMinute", isDirectory: true)
        try FileManager.default.createDirectory(
            at: folder, withIntermediateDirectories: true,
            attributes: [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
        )
        let descriptor = Darwin.open(folder.appendingPathComponent("state.lock").path,
                                     O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
        guard descriptor >= 0 else { throw StoreError.lockUnavailable }
        defer { Darwin.close(descriptor) }
        // Both processes hold this only for small state/shield operations.
        // Blocking avoids dropping the only threshold callback on contention.
        // Never request authorization or register monitoring while holding it.
        guard flock(descriptor, LOCK_EX) == 0 else {
            throw StoreError.lockUnavailable
        }
        defer { flock(descriptor, LOCK_UN) }
        return try operation(LockedStore(folder: folder))
    }
}

struct LockedStore {
    let folder: URL

    func configuration() throws -> SelectionRecord? {
        let record: SelectionRecord? = try read("selection.json")
        try record?.validate()
        return record
    }

    func exhaustion() throws -> ExhaustionRecord? { try read("exhaustion.json") }
    func diagnostic() throws -> MonitorDiagnostic? { try read("diagnostic.json") }
    func needsNewSelection() throws -> Bool { try read("authorization-lost.json") ?? false }

    func saveConfiguration(_ record: SelectionRecord) throws {
        try record.validate()
        try write(record, to: "selection.json")
    }

    func markAuthorizationLost() throws { try write(true, to: "authorization-lost.json") }
    func markSelectionRenewed() throws { try write(false, to: "authorization-lost.json") }
    func saveExhaustion(_ record: ExhaustionRecord) throws { try write(record, to: "exhaustion.json") }
    func saveDiagnostic(_ record: MonitorDiagnostic) throws { try write(record, to: "diagnostic.json") }

    private func read<T: Decodable>(_ name: String) throws -> T? {
        let file = folder.appendingPathComponent(name)
        // Only a genuinely absent file means "no record". Corruption/protection errors throw.
        do {
            return try JSONDecoder().decode(T.self, from: Data(contentsOf: file))
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
            return nil
        }
    }

    private func write<T: Encodable>(_ value: T, to name: String) throws {
        try JSONEncoder().encode(value).write(
            to: folder.appendingPathComponent(name),
            options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication]
        )
    }
}
