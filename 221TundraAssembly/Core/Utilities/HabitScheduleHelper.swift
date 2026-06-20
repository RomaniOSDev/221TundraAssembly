import Foundation

enum HabitScheduleHelper {
    static func isDue(on date: Date, frequency: HabitFrequency, anchorWeekday: Int, calendar: Calendar = .current) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        let isWeekend = weekday == 1 || weekday == 7

        switch frequency {
        case .daily:
            return true
        case .weekdays:
            return !isWeekend
        case .weekends:
            return isWeekend
        case .weekly:
            return weekday == anchorWeekday
        }
    }

    static func defaultAnchorWeekday(for date: Date = Date(), calendar: Calendar = .current) -> Int {
        calendar.component(.weekday, from: date)
    }
}
