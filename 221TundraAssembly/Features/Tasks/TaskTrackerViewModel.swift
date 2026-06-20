import Combine
import Foundation
import SwiftUI

@MainActor
final class TaskTrackerViewModel: ObservableObject {
    @Published var showAddSheet = false
    @Published var showSuccessCheckmark = false
    @Published var fadingTaskID: UUID?
    @Published var searchText = ""
    @Published var selectedFilter: TaskFilterOption = .all

    private var store: AppDataStore?

    func configure(store: AppDataStore) {
        self.store = store
    }

    var incompleteTasks: [TaskItem] {
        filteredTasks.filter { !$0.isCompleted }
    }

    var completedTasks: [TaskItem] {
        filteredTasks.filter(\.isCompleted)
    }

    private var filteredTasks: [TaskItem] {
        store?.filteredTasks(searchText: searchText, filter: selectedFilter) ?? []
    }

    func focusLabel(for task: TaskItem) -> String? {
        guard let store else { return nil }
        let minutes = store.focusMinutesToday(for: task.id)
        guard minutes > 0 else { return nil }
        return "\(minutes) min focused today"
    }

    func addTask(
        title: String,
        category: TaskCategory,
        priority: TaskPriority,
        dueDate: Date,
        recurrence: TaskRecurrence
    ) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let store else { return false }

        let task = TaskItem(
            title: trimmed,
            category: category,
            priority: priority,
            dueDate: dueDate,
            recurrence: recurrence
        )
        store.addTask(task)
        store.checkAchievements()
        showSuccessCheckmark = true
        return true
    }

    func completeTask(id: UUID) {
        guard let store else { return }
        fadingTaskID = id
        Task { @MainActor in
            withAnimation(.easeInOut(duration: 0.3)) {
                store.toggleTaskCompletion(id: id)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.fadingTaskID = nil
        }
        showSuccessCheckmark = true
    }

    func deleteTask(id: UUID) {
        store?.deleteTask(id: id)
        HapticManager.lightTap()
    }

    func toggleCompletion(id: UUID) {
        guard let store, let task = store.tasks.first(where: { $0.id == id }) else { return }
        if !task.isCompleted {
            completeTask(id: id)
        } else {
            store.toggleTaskCompletion(id: id)
            HapticManager.lightTap()
        }
    }
}
