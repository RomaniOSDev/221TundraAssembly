import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppDataStore
    @Binding var selectedTab: AppTab

    @State private var showAddBlockSheet = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    private var formattedDate: String {
        Date().formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    var body: some View {
        NavigationStack {
            AppScreenBackground {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        heroWidget
                        quickActionsWidget
                        statsWidgetRow
                        tasksWidget
                        habitsWidget
                        focusWidget
                        weeklyWidget
                        motivationWidget
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("Home")
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

    // MARK: - Hero

    private var heroWidget: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Text(greeting)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(formattedDate)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))

                HStack(spacing: 10) {
                    ZStack {
                        AppProgressRing(
                            progress: Double(store.dayProgressPercentage()) / 100.0,
                            lineWidth: 7,
                            size: 64
                        )
                        Text("\(store.dayProgressPercentage())%")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppPrimary"))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Progress")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(progressSubtitle)
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                    }
                }
            }

            Spacer(minLength: 0)

            HomeDeskIllustration()
                .frame(width: 130)
        }
        .padding(16)
        .appCard()
    }

    private var progressSubtitle: String {
        let progress = store.dayProgressPercentage()
        if progress >= 100 { return "Perfect day achieved." }
        if progress == 0 { return "Start with one small win." }
        return "Keep going — you're doing great."
    }

    // MARK: - Quick Actions

    private var quickActionsWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Quick Actions", icon: "bolt.fill")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                HomeQuickActionWidget(title: "New Task", icon: "plus.circle.fill") {
                    selectedTab = .tasks
                }
                HomeQuickActionWidget(title: "Start Focus", icon: "play.circle.fill") {
                    selectedTab = .focus
                }
                HomeQuickActionWidget(title: "Log Habit", icon: "checkmark.circle.fill") {
                    selectedTab = .focus
                }
                HomeQuickActionWidget(title: "View Stats", icon: "chart.bar.fill") {
                    selectedTab = .stats
                }
            }
        }
    }

    // MARK: - Stats Row

    private var statsWidgetRow: some View {
        HStack(spacing: 10) {
            HomeStatWidget(
                value: "\(store.focusMinutesTodayTotal())m",
                label: "Focus",
                icon: "timer"
            )
            HomeStatWidget(
                value: "\(store.sessionsToday().count)",
                label: "Sessions",
                icon: "bolt.fill"
            )
            HomeStatWidget(
                value: "\(store.currentAppUsageStreak)",
                label: "Streak",
                icon: "flame.fill"
            )
        }
    }

    // MARK: - Tasks Widget

    private var tasksWidget: some View {
        HomeWidgetShell(
            title: "Today's Tasks",
            subtitle: "Top priorities for your plan",
            actionTitle: "Open Task Tracker",
            action: { selectedTab = .tasks },
            illustration: { HomeMotivationIllustration().scaleEffect(0.85) }
        ) {
            let tasks = store.topPlanTasks()
            if tasks.isEmpty {
                AppEmptyStateView(
                    icon: "list.bullet.rectangle",
                    title: "No tasks yet",
                    subtitle: "Add tasks and pin your top 3."
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(tasks) { task in
                        HomeMiniTaskRow(
                            task: task,
                            focusMinutes: store.focusMinutesToday(for: task.id)
                        ) {
                            store.toggleTaskCompletion(id: task.id)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Habits Widget

    private var habitsWidget: some View {
        HomeWidgetShell(
            title: "Habits Today",
            subtitle: "Tap a card to check in",
            actionTitle: "Open Habit Log",
            action: { selectedTab = .focus },
            illustration: {
                HomeHabitIllustration(
                    progress: habitProgressRatio
                )
            }
        ) {
            let habits = store.habitsDueToday()
            if habits.isEmpty {
                AppEmptyStateView(
                    icon: "checklist",
                    title: "No habits scheduled",
                    subtitle: "Create a daily or weekly habit."
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(habits) { habit in
                            HomeHabitMiniCard(
                                habit: habit,
                                isCompleted: store.isHabitCompletedToday(habit.id)
                            ) {
                                store.toggleHabitCompletion(id: habit.id)
                            }
                        }
                    }
                }
            }
        }
    }

    private var habitProgressRatio: Double {
        let due = store.habitsDueToday()
        guard !due.isEmpty else { return 0 }
        let done = due.filter { store.isHabitCompletedToday($0.id) }.count
        return Double(done) / Double(due.count)
    }

    // MARK: - Focus Widget

    private var focusWidget: some View {
        HomeWidgetShell(
            title: "Focus Blocks",
            subtitle: "Planned deep work for today",
            actionTitle: "Add Focus Block",
            action: { showAddBlockSheet = true },
            illustration: { HomeFocusWaveIllustration() }
        ) {
            let blocks = store.todaysFocusBlocks()
            if blocks.isEmpty {
                VStack(spacing: 10) {
                    AppEmptyStateView(
                        icon: "timer",
                        title: "No blocks planned",
                        subtitle: "Schedule a focus block to stay on track."
                    )
                    AppPrimaryButton(title: "Plan First Block", icon: "plus") {
                        showAddBlockSheet = true
                    }
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(blocks.prefix(3)) { block in
                        HomeFocusBlockMini(block: block) {
                            HapticManager.lightTap()
                            selectedTab = .focus
                        }
                    }
                }
            }
        }
    }

    // MARK: - Weekly Widget

    private var weeklyWidget: some View {
        HomeWidgetShell(
            title: "Weekly Snapshot",
            subtitle: "Focus minutes over the last 7 days",
            actionTitle: "See Full Insights",
            action: { selectedTab = .stats },
            illustration: {
                HomeWeeklyIllustration(
                    values: store.weeklyFocusStats().map(\.minutes)
                )
            }
        ) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Best Day")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(store.bestFocusDayThisWeek())
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Text("Habit Rate")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text("\(store.weeklyHabitCompletionRate())%")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color("AppAccent"))
                }
            }
            .padding(12)
            .appInsetPanel(cornerRadius: 12)
        }
    }

    // MARK: - Motivation

    private var motivationWidget: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Stay Consistent")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Small actions every day build lasting productivity. Pin tasks, finish a focus block, and check one habit.")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(4)
                    .minimumScaleFactor(0.7)
            }
            HomeMotivationIllustration()
        }
        .padding(16)
        .appCard(elevated: false)
    }
}
