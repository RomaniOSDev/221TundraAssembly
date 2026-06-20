import Combine
import Foundation

@MainActor
final class HabitLogViewModel: ObservableObject {
    @Published var showAddSheet = false
    @Published var editingHabit: HabitItem?
    @Published var pulsingHabitID: UUID?

    private var store: AppDataStore?

    func configure(store: AppDataStore) {
        self.store = store
    }

    var habits: [HabitItem] {
        store?.habits ?? []
    }

    func isCompleted(_ habit: HabitItem) -> Bool {
        store?.isHabitCompletedToday(habit.id) ?? false
    }

    func toggleHabit(_ habit: HabitItem) {
        guard let store else { return }
        let wasCompleted = isCompleted(habit)
        store.toggleHabitCompletion(id: habit.id)

        if !wasCompleted {
            pulsingHabitID = habit.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.pulsingHabitID = nil
            }
        }
    }

    func deleteHabit(id: UUID) {
        store?.deleteHabit(id: id)
        HapticManager.lightTap()
    }

    func addHabit(name: String, frequency: HabitFrequency) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let store else { return false }
        store.addHabit(HabitItem(name: trimmed, frequency: frequency))
        store.checkAchievements()
        return true
    }

    func updateHabit(_ habit: HabitItem, name: String, frequency: HabitFrequency) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let store else { return false }
        var updated = habit
        updated.name = trimmed
        updated.frequency = frequency
        if frequency == .weekly && habit.frequency != .weekly {
            updated.anchorWeekday = HabitScheduleHelper.defaultAnchorWeekday()
        }
        store.updateHabit(updated)
        HapticManager.mediumTap()
        SoundManager.playSuccess()
        return true
    }
}
