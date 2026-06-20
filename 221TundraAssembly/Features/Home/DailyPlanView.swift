import SwiftUI

struct DailyPlanView: View {
    @EnvironmentObject private var store: AppDataStore
    @Binding var selectedTab: AppTab

    @State private var showAddBlockSheet = false

    var body: some View {
        NavigationStack {
            AppScreenBackground {
                ScrollView {
                    VStack(spacing: 22) {
                        progressCard
                        topTasksSection
                        habitsSection
                        focusBlocksSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .appNavigationStyle()
            .onAppear {
                Task { @MainActor in
                    store.refreshDayBoundaries()
                }
            }
            .sheet(isPresented: $showAddBlockSheet) {
                AddFocusBlockSheet()
            }
        }
    }

    private var progressCard: some View {
        DailyProgressHeroCard(
            progress: store.dayProgressPercentage(),
            focusMinutes: store.focusMinutesTodayTotal(),
            sessions: store.sessionsToday().count,
            habitsDone: store.habitsDueToday().filter { store.isHabitCompletedToday($0.id) }.count,
            habitsTotal: max(store.habitsDueToday().count, 1)
        )
    }

    private var topTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(
                title: "Top 3 Tasks",
                icon: "list.bullet.rectangle",
                actionTitle: "All Tasks"
            ) {
                HapticManager.lightTap()
                selectedTab = .tasks
            }

            let topTasks = store.topPlanTasks()
            if topTasks.isEmpty {
                AppEmptyStateView(
                    icon: "list.bullet.rectangle",
                    title: "No tasks for today",
                    subtitle: "Add tasks and pin your top priorities."
                )
            } else {
                ForEach(topTasks) { task in
                    TaskCell(
                        task: task,
                        focusMinutesToday: store.focusMinutesToday(for: task.id),
                        isPinned: store.isInDailyPlan(task.id),
                        onToggle: { store.toggleTaskCompletion(id: task.id) },
                        onPin: { store.toggleDailyPlanTask(task.id) }
                    )
                }
            }
        }
    }

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(
                title: "Habits Today",
                icon: "checklist",
                actionTitle: "All Habits"
            ) {
                HapticManager.lightTap()
                selectedTab = .focus
            }

            let dueHabits = store.habitsDueToday()
            if dueHabits.isEmpty {
                AppEmptyStateView(
                    icon: "checklist",
                    title: "No habits scheduled",
                    subtitle: "Create habits with daily or weekly frequency."
                )
            } else {
                ForEach(dueHabits) { habit in
                    HabitCell(
                        habit: habit,
                        isCompleted: store.isHabitCompletedToday(habit.id),
                        onToggle: { store.toggleHabitCompletion(id: habit.id) }
                    )
                }
            }
        }
    }

    private var focusBlocksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(
                title: "Focus Blocks",
                icon: "timer",
                actionTitle: "Add"
            ) {
                HapticManager.lightTap()
                showAddBlockSheet = true
            }

            let blocks = store.todaysFocusBlocks()
            if blocks.isEmpty {
                AppEmptyStateView(
                    icon: "timer",
                    title: "No focus blocks planned",
                    subtitle: "Structure your day with timed focus sessions."
                )
            } else {
                ForEach(blocks) { block in
                    FocusBlockCell(
                        block: block,
                        onStart: block.isCompleted ? nil : {
                            HapticManager.lightTap()
                            selectedTab = .focus
                        },
                        onDelete: {
                            HapticManager.lightTap()
                            store.removeFocusBlock(id: block.id)
                        }
                    )
                }
            }
        }
    }
}

struct AddFocusBlockSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTaskId: UUID?
    @State private var plannedMinutes: Double = 25

    var body: some View {
        NavigationStack {
            AppSheetBackground {
                ScrollView {
                    VStack(spacing: 16) {
                        AppFormCard(title: "Link to Task") {
                            VStack(spacing: 10) {
                                taskOption(title: "General Focus", subtitle: "Open focus session", taskId: nil)
                                ForEach(store.tasks.filter { !$0.isCompleted }) { task in
                                    taskOption(title: task.title, subtitle: task.category.rawValue, taskId: task.id)
                                }
                            }
                        }

                        AppFormCard(title: "Duration") {
                            VStack(spacing: 14) {
                                Text("\(Int(plannedMinutes)) min")
                                    .font(.title.bold())
                                    .foregroundStyle(Color("AppPrimary"))
                                Slider(value: $plannedMinutes, in: 5...120, step: 5)
                                    .tint(Color("AppAccent"))
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Plan Focus Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveBlock()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func taskOption(title: String, subtitle: String, taskId: UUID?) -> some View {
        let isSelected = selectedTaskId == taskId
        return Button {
            HapticManager.lightTap()
            selectedTaskId = taskId
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color("AppPrimary") : Color("AppTextSecondary"))
            }
            .padding(12)
            .background(Color("AppBackground").opacity(isSelected ? 0.65 : 0.35))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func saveBlock() {
        let title: String
        let taskId: UUID?
        if let id = selectedTaskId, let task = store.tasks.first(where: { $0.id == id }) {
            title = task.title
            taskId = id
        } else {
            title = "General Focus"
            taskId = nil
        }
        store.addFocusBlock(taskId: taskId, taskTitle: title, plannedMinutes: Int(plannedMinutes))
        dismiss()
    }
}
