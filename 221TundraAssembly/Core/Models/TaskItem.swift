import Foundation

enum TaskCategory: String, Codable, CaseIterable, Identifiable {
    case work = "Work"
    case personal = "Personal"
    case health = "Health"
    case learning = "Learning"
    case other = "Other"

    var id: String { rawValue }
}

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }
}

enum TaskRecurrence: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case daily = "Daily"
    case weekdays = "Weekdays"
    case weekly = "Weekly"

    var id: String { rawValue }
}

enum TaskFilterOption: String, CaseIterable, Identifiable {
    case all = "All"
    case today = "Today"
    case highPriority = "High"
    case overdue = "Overdue"

    var id: String { rawValue }
}

struct TaskItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var category: TaskCategory
    var priority: TaskPriority
    var dueDate: Date
    var isCompleted: Bool
    var recurrence: TaskRecurrence
    var lastCompletedDate: Date?

    init(
        id: UUID = UUID(),
        title: String,
        category: TaskCategory = .work,
        priority: TaskPriority = .medium,
        dueDate: Date = Date(),
        isCompleted: Bool = false,
        recurrence: TaskRecurrence = .none,
        lastCompletedDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.priority = priority
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.recurrence = recurrence
        self.lastCompletedDate = lastCompletedDate
    }
}
