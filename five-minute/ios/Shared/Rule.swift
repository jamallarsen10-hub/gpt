import DeviceActivity
import ManagedSettings

enum Rule {
    static let activity = DeviceActivityName("five-minute.daily")
    static let event = DeviceActivityEvent.Name("five-minute.exhausted")
    static let store = ManagedSettingsStore.Name("five-minute.shield")

    static var schedule: DeviceActivitySchedule {
        DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )
    }
}
