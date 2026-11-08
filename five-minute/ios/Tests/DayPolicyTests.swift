import Foundation

@main
enum DayPolicyTests {
    static func main() {
        var checks = 0
        func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
            guard condition() else { fatalError(message) }
            checks += 1
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        func date(_ iso: String) -> Date { ISO8601DateFormatter().date(from: iso)! }

        expect(DayPolicy.budgetSeconds == 300, "Budget must remain five minutes")
        expect(!DayPolicy.isBlocked(exhaustedDay: nil, today: 20261108), "Fresh day is open")
        expect(DayPolicy.isBlocked(exhaustedDay: 20261108, today: 20261108), "Same-day block persists")
        expect(!DayPolicy.isBlocked(exhaustedDay: 20261108, today: 20261109), "Next day resets")
        expect(DayPolicy.isBlocked(exhaustedDay: 20261109, today: 20261108), "Clock rollback stays blocked")
        expect(DayPolicy.dayKey(for: date("2026-11-09T04:59:59Z"), calendar: calendar) == 20261108,
               "Day before local midnight")
        expect(DayPolicy.dayKey(for: date("2026-11-09T05:00:00Z"), calendar: calendar) == 20261109,
               "Day after local midnight")
        expect(DayPolicy.dayKey(for: date("2026-11-01T05:30:00Z"), calendar: calendar) == 20261101,
               "First fall-back hour")
        expect(DayPolicy.dayKey(for: date("2026-11-01T06:30:00Z"), calendar: calendar) == 20261101,
               "Repeated fall-back hour remains same day")
        expect(DayPolicy.dayKey(for: date("2026-03-08T06:59:59Z"), calendar: calendar) == 20260308,
               "Before spring-forward")
        expect(DayPolicy.dayKey(for: date("2026-03-08T07:00:00Z"), calendar: calendar) == 20260308,
               "After spring-forward remains same day")
        expect(!DayPolicy.isBlocked(exhaustedDay: 20261231, today: 20270101), "New year resets")
        print("Passed \(checks) calendar/budget policy checks. OS enforcement is not simulated here.")
    }
}
