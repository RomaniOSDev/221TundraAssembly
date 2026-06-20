import Foundation

enum HabitFrequency: String, Codable, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekdays = "Weekdays"
    case weekends = "Weekends"
    case weekly = "Weekly"

    var id: String { rawValue }
}

struct HabitItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var frequency: HabitFrequency
    var streak: Int
    var anchorWeekday: Int

    init(
        id: UUID = UUID(),
        name: String,
        frequency: HabitFrequency = .daily,
        streak: Int = 0,
        anchorWeekday: Int = HabitScheduleHelper.defaultAnchorWeekday()
    ) {
        self.id = id
        self.name = name
        self.frequency = frequency
        self.streak = streak
        self.anchorWeekday = anchorWeekday
    }
}
