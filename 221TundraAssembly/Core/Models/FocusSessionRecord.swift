import Foundation

struct FocusSessionRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let taskId: UUID?
    let taskTitle: String
    let durationSeconds: Int
    let completedAt: Date
    var note: String

    init(
        id: UUID = UUID(),
        taskId: UUID?,
        taskTitle: String,
        durationSeconds: Int,
        completedAt: Date = Date(),
        note: String = ""
    ) {
        self.id = id
        self.taskId = taskId
        self.taskTitle = taskTitle
        self.durationSeconds = durationSeconds
        self.completedAt = completedAt
        self.note = note
    }

    var durationLabel: String {
        let minutes = durationSeconds / 60
        if minutes < 1 { return "< 1 min" }
        return minutes == 1 ? "1 min" : "\(minutes) min"
    }
}

struct FocusBlockPlan: Identifiable, Codable, Equatable {
    let id: UUID
    var taskId: UUID?
    var taskTitle: String
    var plannedMinutes: Int
    var isCompleted: Bool
    var dateKey: String

    init(
        id: UUID = UUID(),
        taskId: UUID?,
        taskTitle: String,
        plannedMinutes: Int,
        isCompleted: Bool = false,
        dateKey: String
    ) {
        self.id = id
        self.taskId = taskId
        self.taskTitle = taskTitle
        self.plannedMinutes = plannedMinutes
        self.isCompleted = isCompleted
        self.dateKey = dateKey
    }
}

struct DailyFocusStat: Identifiable {
    let id: String
    let date: Date
    let minutes: Int
    let weekdayLabel: String
}

struct HabitHeatmapDay: Identifiable {
    let id: String
    let date: Date
    let completionCount: Int
}
