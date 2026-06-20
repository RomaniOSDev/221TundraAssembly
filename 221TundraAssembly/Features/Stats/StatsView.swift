import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            AppScreenBackground {
                ScrollView {
                    VStack(spacing: 20) {
                        summaryCard
                        WeeklyInsightsView()
                        HabitCalendarView()
                        achievementsGrid
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
            .appNavigationStyle()
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            AppSectionHeader(title: "Summary", icon: "chart.bar.fill")

            HStack(spacing: 10) {
                AppMetricTile(value: "\(store.tasksCompleted)", label: "Tasks Done", icon: "checkmark.circle.fill")
                AppMetricTile(value: "\(store.totalFocusMinutes)", label: "Focus Min", icon: "timer")
                AppMetricTile(value: "\(store.currentAppUsageStreak)", label: "Day Streak", icon: "flame.fill")
            }
        }
        .padding(16)
        .appCard()
    }

    private var achievementsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Badges", icon: "star.fill")

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(AchievementDefinition.all) { achievement in
                    AchievementCell(
                        achievement: achievement,
                        unlocked: store.isAchievementUnlocked(achievement.id)
                    )
                }
            }
        }
    }
}
