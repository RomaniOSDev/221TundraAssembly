import Charts
import SwiftUI

struct WeeklyInsightsView: View {
    @EnvironmentObject private var store: AppDataStore

    private var focusStats: [DailyFocusStat] {
        store.weeklyFocusStats()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            AppSectionHeader(title: "Weekly Review", icon: "calendar")

            if focusStats.allSatisfy({ $0.minutes == 0 }) {
                AppEmptyStateView(
                    icon: "chart.bar",
                    title: "No focus data yet",
                    subtitle: "Complete sessions to unlock weekly trends."
                )
            } else {
                VStack(spacing: 14) {
                    Chart(focusStats) { stat in
                        BarMark(
                            x: .value("Day", stat.weekdayLabel),
                            y: .value("Minutes", stat.minutes)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .cornerRadius(6)
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(Color("AppTextSecondary").opacity(0.25))
                            AxisValueLabel()
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                    .frame(height: 190)

                    HStack(spacing: 10) {
                        insightTile(
                            value: "\(store.weeklyHabitCompletionRate())%",
                            label: "Habit Rate",
                            icon: "checklist"
                        )
                        insightTile(
                            value: "\(store.weeklyTasksCompletedCount())",
                            label: "Tasks Done",
                            icon: "checkmark.circle"
                        )
                    }

                    HStack(spacing: 10) {
                        AppIconBadge(icon: "star.fill", size: 36, style: .primary)
                        Text("Best focus day: \(store.bestFocusDayThisWeek())")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Spacer()
                    }
                    .padding(12)
                    .appInsetPanel(cornerRadius: 14)
                }
                .padding(16)
                .appCard(elevated: false)
            }
        }
    }

    private func insightTile(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            AppIconBadge(icon: icon, size: 34, style: .accent)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .appInsetPanel(cornerRadius: 14)
    }
}
