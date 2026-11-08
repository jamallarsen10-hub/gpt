import Foundation

/// Calendar policy only. Apple, not this app, measures foreground usage.
enum DayPolicy {
    static let budgetSeconds = 300

    static func dayKey(for date: Date, calendar: Calendar = .current) -> Int {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return (parts.year ?? 0) * 10_000 + (parts.month ?? 0) * 100 + (parts.day ?? 0)
    }

    /// A future marker stays blocked conservatively after a wall-clock rollback.
    static func isBlocked(exhaustedDay: Int?, today: Int) -> Bool {
        guard let exhaustedDay else { return false }
        return exhaustedDay >= today
    }
}
