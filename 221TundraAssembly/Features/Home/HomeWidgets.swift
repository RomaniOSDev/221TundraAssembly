import SwiftUI

struct HomeWidgetShell<Content: View, Illustration: View>: View {
    let title: String
    let subtitle: String?
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    @ViewBuilder let illustration: () -> Illustration
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                    }
                }
                Spacer()
                illustration()
            }

            content()

            if let actionTitle, let action {
                Button(action: action) {
                    HStack {
                        Text(actionTitle)
                            .font(.caption.weight(.bold))
                        Image(systemName: "arrow.right")
                            .font(.caption2.bold())
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .padding(16)
        .appCard(elevated: false)
    }
}

struct HomeQuickActionWidget: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.lightTap()
            SoundManager.playTick()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                AppIconBadge(icon: icon, size: 40, iconSize: .body, style: .primary)
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
            .padding(14)
            .appCard(cornerRadius: 16, elevated: false)
        }
        .buttonStyle(.plain)
    }
}

struct HomeMiniTaskRow: View {
    let task: TaskItem
    let focusMinutes: Int
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? Color("AppAccent") : Color("AppTextSecondary"))
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .strikethrough(task.isCompleted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    if focusMinutes > 0 {
                        Text("\(focusMinutes) min focused")
                            .font(.caption2)
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .appInsetPanel(cornerRadius: 12)
        }
        .buttonStyle(.plain)
    }
}

struct HomeHabitMiniCard: View {
    let habit: HabitItem
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 10) {
                HomeHabitIllustration(progress: isCompleted ? 1.0 : 0.35)
                Text(habit.name)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .frame(width: 92, alignment: .leading)
                HStack {
                    Image(systemName: isCompleted ? "checkmark.seal.fill" : "circle")
                        .foregroundStyle(isCompleted ? Color("AppAccent") : Color("AppTextSecondary"))
                    Text("\(habit.streak)d")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
            .padding(12)
            .frame(width: 116)
            .appInsetPanel(cornerRadius: 16)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        isCompleted ? AppGradients.unlockedGlow : AppGradients.cardBorder,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct HomeStatWidget: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            AppIconBadge(icon: icon, size: 34, iconSize: .caption, style: .accent)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .appCard(cornerRadius: 14, elevated: false)
    }
}

struct HomeFocusBlockMini: View {
    let block: FocusBlockPlan
    var onStart: (() -> Void)?

    var body: some View {
        HStack(spacing: 10) {
            AppIconBadge(
                icon: block.isCompleted ? "checkmark.circle.fill" : "hourglass",
                size: 36,
                style: block.isCompleted ? .success : .primary
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(block.taskTitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("\(block.plannedMinutes) min")
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
            if !block.isCompleted, let onStart {
                Button("Go", action: onStart)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color("AppBackground"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .appGradientCapsule()
            }
        }
        .padding(10)
        .appInsetPanel(cornerRadius: 12)
    }
}
