import SwiftUI

struct HabitCalendarView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    private var heatmap: [HabitHeatmapDay] {
        store.habitHeatmap(days: 84)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Habit Calendar", icon: "square.grid.3x3.fill")

            Text("Last 12 weeks")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppTextSecondary"))

            if heatmap.allSatisfy({ $0.completionCount == 0 }) {
                AppEmptyStateView(
                    icon: "calendar",
                    title: "Calendar is empty",
                    subtitle: "Check in habits to fill your activity grid."
                )
            } else {
                VStack(spacing: 12) {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(heatmap) { day in
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(cellFill(for: day.completionCount))
                                .frame(height: 15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .stroke(Color("AppTextSecondary").opacity(0.08), lineWidth: 0.5)
                                )
                                .accessibilityLabel(accessibilityLabel(for: day))
                        }
                    }

                    HStack(spacing: 8) {
                        Text("Less")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color("AppTextSecondary"))
                        ForEach(0..<4, id: \.self) { level in
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(cellColor(for: level))
                                .frame(width: 14, height: 14)
                        }
                        Text("More")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .padding(16)
                .appCard(elevated: false)
            }
        }
    }

    private func cellFill(for count: Int) -> some ShapeStyle {
        switch count {
        case 0:
            return AnyShapeStyle(AppGradients.insetPanel)
        case 1:
            return AnyShapeStyle(Color("AppAccent").opacity(0.38))
        case 2:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color("AppAccent").opacity(0.55), Color("AppPrimary").opacity(0.35)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        default:
            return AnyShapeStyle(AppGradients.primaryButton)
        }
    }

    private func cellColor(for count: Int) -> Color {
        switch count {
        case 0:
            return Color("AppBackground")
        case 1:
            return Color("AppAccent").opacity(0.35)
        case 2:
            return Color("AppAccent").opacity(0.62)
        default:
            return Color("AppPrimary")
        }
    }

    private func accessibilityLabel(for day: HabitHeatmapDay) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: day.date)): \(day.completionCount) habits"
    }
}
