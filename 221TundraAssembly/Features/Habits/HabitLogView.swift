import SwiftUI

struct HabitLogView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = HabitLogViewModel()
    @State private var showAllHabits = false

    private var displayedHabits: [HabitItem] {
        showAllHabits ? store.habits : store.habitsDueToday()
    }

    var body: some View {
        NavigationStack {
            AppScreenBackground {
                ZStack {
                    VStack(spacing: 0) {
                        filterBar

                        if store.habits.isEmpty {
                        ScrollView {
                            AppEmptyStateView(
                                icon: "checklist",
                                title: "No Habits Yet!",
                                subtitle: "Tap + to add your first habit."
                            )
                            .padding(.horizontal, 16)
                            .padding(.top, 40)
                        }
                    } else if displayedHabits.isEmpty {
                        ScrollView {
                            AppEmptyStateView(
                                icon: "calendar",
                                title: "No habits scheduled for today",
                                subtitle: "Toggle 'Show all habits' or adjust frequency."
                            )
                            .padding(.horizontal, 16)
                            .padding(.top, 40)
                        }
                    } else {
                        List {
                            ForEach(displayedHabits) { habit in
                                HabitCell(
                                    habit: habit,
                                    isCompleted: viewModel.isCompleted(habit),
                                    isDueToday: store.isHabitDueToday(habit),
                                    isPulsing: viewModel.pulsingHabitID == habit.id,
                                    showNotTodayLabel: showAllHabits,
                                    onToggle: { viewModel.toggleHabit(habit) }
                                )
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteHabit(id: habit.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button {
                                        viewModel.editingHabit = habit
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(Color("AppPrimary"))
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        AppFloatingActionButton {
                            viewModel.showAddSheet = true
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 16)
                }
                }
            }
            .navigationTitle("Daily Habit Log")
            .navigationBarTitleDisplayMode(.large)
            .appNavigationStyle()
            .sheet(isPresented: $viewModel.showAddSheet) {
                HabitFormSheet(title: "New Habit") { name, frequency in
                    viewModel.addHabit(name: name, frequency: frequency)
                }
            }
            .sheet(item: $viewModel.editingHabit) { habit in
                HabitFormSheet(title: "Edit Habit", initialName: habit.name, initialFrequency: habit.frequency) { name, frequency in
                    viewModel.updateHabit(habit, name: name, frequency: frequency)
                }
            }
            .onAppear {
                viewModel.configure(store: store)
            }
        }
    }

    private var filterBar: some View {
        HStack {
            AppIconBadge(icon: showAllHabits ? "calendar" : "sun.max.fill", size: 34, style: .primary)
            Toggle(isOn: $showAllHabits) {
                Text("Show all habits")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            .tint(Color("AppPrimary"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .appCard(cornerRadius: 14, elevated: false)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .onChange(of: showAllHabits) { _ in
            HapticManager.lightTap()
        }
    }
}

struct HabitFormSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    var initialName: String = ""
    var initialFrequency: HabitFrequency = .daily
    let onSave: (String, HabitFrequency) -> Bool

    @State private var name: String
    @State private var frequency: HabitFrequency
    @State private var showError = false
    @State private var shakeAmount: CGFloat = 0

    init(title: String, initialName: String = "", initialFrequency: HabitFrequency = .daily, onSave: @escaping (String, HabitFrequency) -> Bool) {
        self.title = title
        self.initialName = initialName
        self.initialFrequency = initialFrequency
        self.onSave = onSave
        _name = State(initialValue: initialName)
        _frequency = State(initialValue: initialFrequency)
    }

    var body: some View {
        NavigationStack {
            AppSheetBackground {
                ScrollView {
                    VStack(spacing: 16) {
                        AppFormCard(title: "Habit Details") {
                            VStack(alignment: .leading, spacing: 10) {
                                TextField("Habit Name", text: $name)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .padding(12)
                                    .appInsetPanel(cornerRadius: 12)
                                    .modifier(ShakeEffect(animatableData: shakeAmount))

                                if showError {
                                    Text("Please enter a habit name.")
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                }
                            }
                        }

                        AppFormCard(title: "Schedule") {
                            VStack(alignment: .leading, spacing: 12) {
                                Picker("Frequency", selection: $frequency) {
                                    ForEach(HabitFrequency.allCases) { freq in
                                        Text(freq.rawValue).tag(freq)
                                    }
                                }
                                .tint(Color("AppPrimary"))

                                Text(frequencyHint)
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var frequencyHint: String {
        switch frequency {
        case .daily: return "Shown every day."
        case .weekdays: return "Shown Monday through Friday."
        case .weekends: return "Shown on Saturday and Sunday."
        case .weekly: return "Shown once per week on the same weekday."
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            HapticManager.warning()
            showError = true
            withAnimation(.default) { shakeAmount += 1 }
            return
        }
        if onSave(trimmed, frequency) {
            dismiss()
        }
    }
}
