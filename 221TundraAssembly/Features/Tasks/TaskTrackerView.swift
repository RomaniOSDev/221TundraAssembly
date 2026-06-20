import SwiftUI

struct TaskTrackerView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = TaskTrackerViewModel()

    var body: some View {
        NavigationStack {
            AppScreenBackground {
                ZStack {
                    VStack(spacing: 0) {
                        searchAndFilters

                        if store.tasks.isEmpty {
                            ScrollView {
                                AppEmptyStateView(
                                    icon: "list.bullet.rectangle",
                                    title: "No tasks yet",
                                    subtitle: "Tap + to start organizing your day."
                                )
                                .padding(.horizontal, 16)
                                .padding(.top, 40)
                            }
                        } else if viewModel.incompleteTasks.isEmpty && viewModel.completedTasks.isEmpty {
                            ScrollView {
                                AppEmptyStateView(
                                    icon: "magnifyingglass",
                                    title: "No matching tasks",
                                    subtitle: "Try a different search or filter."
                                )
                                .padding(.horizontal, 16)
                                .padding(.top, 40)
                            }
                        } else {
                            List {
                            if !viewModel.incompleteTasks.isEmpty {
                                Section {
                                    ForEach(viewModel.incompleteTasks) { task in
                                        TaskCell(
                                            task: task,
                                            focusMinutesToday: store.focusMinutesToday(for: task.id),
                                            isPinned: store.isInDailyPlan(task.id),
                                            isFading: viewModel.fadingTaskID == task.id,
                                            onToggle: { viewModel.toggleCompletion(id: task.id) }
                                        )
                                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                viewModel.deleteTask(id: task.id)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button {
                                                viewModel.completeTask(id: task.id)
                                            } label: {
                                                Label("Done", systemImage: "checkmark")
                                            }
                                            .tint(Color("AppAccent"))
                                        }
                                    }
                                } header: {
                                    AppListSectionHeader(title: "Active")
                                }
                            }

                            if !viewModel.completedTasks.isEmpty {
                                Section {
                                    ForEach(viewModel.completedTasks) { task in
                                        TaskCell(
                                            task: task,
                                            focusMinutesToday: store.focusMinutesToday(for: task.id),
                                            isPinned: store.isInDailyPlan(task.id),
                                            onToggle: { viewModel.toggleCompletion(id: task.id) }
                                        )
                                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                viewModel.deleteTask(id: task.id)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                } header: {
                                    AppListSectionHeader(title: "Completed")
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

                SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessCheckmark)
                }
            }
            .navigationTitle("Task Tracker")
            .navigationBarTitleDisplayMode(.large)
            .appNavigationStyle()
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddTaskSheet { title, category, priority, dueDate, recurrence in
                    viewModel.addTask(
                        title: title,
                        category: category,
                        priority: priority,
                        dueDate: dueDate,
                        recurrence: recurrence
                    )
                }
            }
            .onAppear {
                viewModel.configure(store: store)
                Task { @MainActor in
                    store.refreshDayBoundaries()
                }
            }
        }
    }

    private var searchAndFilters: some View {
        VStack(spacing: 10) {
            AppSearchBar(text: $viewModel.searchText, placeholder: "Search tasks...")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TaskFilterOption.allCases) { filter in
                        AppFilterChip(
                            title: filter.rawValue,
                            isSelected: viewModel.selectedFilter == filter
                        ) {
                            HapticManager.lightTap()
                            viewModel.selectedFilter = filter
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (String, TaskCategory, TaskPriority, Date, TaskRecurrence) -> Bool

    @State private var title = ""
    @State private var category: TaskCategory = .work
    @State private var priority: TaskPriority = .medium
    @State private var dueDate = Date()
    @State private var recurrence: TaskRecurrence = .none
    @State private var showError = false
    @State private var shakeAmount: CGFloat = 0

    var body: some View {
        NavigationStack {
            AppSheetBackground {
                ScrollView {
                    VStack(spacing: 16) {
                        AppFormCard(title: "Task Details") {
                            VStack(alignment: .leading, spacing: 10) {
                                TextField("Task Name", text: $title)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .padding(12)
                                    .appInsetPanel(cornerRadius: 12)
                                    .modifier(ShakeEffect(animatableData: shakeAmount))

                                if showError {
                                    Text("Please enter a task name.")
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                }
                            }
                        }

                        AppFormCard(title: "Organization") {
                            VStack(spacing: 14) {
                                Picker("Category", selection: $category) {
                                    ForEach(TaskCategory.allCases) { cat in
                                        Text(cat.rawValue).tag(cat)
                                    }
                                }
                                .tint(Color("AppPrimary"))

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Priority")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color("AppTextSecondary"))
                                    Picker("Priority", selection: $priority) {
                                        ForEach(TaskPriority.allCases) { p in
                                            Text(p.rawValue).tag(p)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }

                                Picker("Repeat", selection: $recurrence) {
                                    ForEach(TaskRecurrence.allCases) { item in
                                        Text(item.rawValue).tag(item)
                                    }
                                }
                                .tint(Color("AppPrimary"))

                                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                                    .tint(Color("AppPrimary"))
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("New Task")
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
                    Button("Save") {
                        saveTask()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func saveTask() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            HapticManager.warning()
            showError = true
            withAnimation(.default) { shakeAmount += 1 }
            return
        }

        if onSave(trimmed, category, priority, dueDate, recurrence) {
            dismiss()
        }
    }
}
