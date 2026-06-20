import SwiftUI

struct TaskCell: View {
    let task: TaskItem
    var focusMinutesToday: Int = 0
    var isPinned: Bool = false
    var isFading: Bool = false
    let onToggle: () -> Void
    var onPin: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 0) {
            priorityStripe

            HStack(spacing: 12) {
                Button(action: onToggle) {
                    ZStack {
                        Circle()
                            .stroke(task.isCompleted ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.45), lineWidth: 2)
                            .frame(width: 28, height: 28)
                        if task.isCompleted {
                            Circle()
                                .fill(Color("AppAccent"))
                                .frame(width: 28, height: 28)
                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundStyle(Color("AppBackground"))
                        }
                    }
                    .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 8) {
                    Text(task.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .strikethrough(task.isCompleted)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)

                    HStack(spacing: 6) {
                        AppTag(text: task.category.rawValue, icon: "folder", tone: .neutral)
                        AppTag(text: task.priority.rawValue, tone: priorityTone)
                        AppTag(text: formattedDueDate, icon: "calendar", tone: isOverdue ? .warning : .neutral)
                    }

                    if hasMetaRow {
                        HStack(spacing: 6) {
                            if task.recurrence != .none {
                                AppTag(text: task.recurrence.rawValue, icon: "repeat", tone: .primary)
                            }
                            if focusMinutesToday > 0 {
                                AppTag(text: "\(focusMinutesToday) min focused", icon: "timer", tone: .accent)
                            }
                            if isPinned {
                                AppTag(text: "Today", icon: "pin.fill", tone: .primary)
                            }
                        }
                    }
                }

                Spacer(minLength: 0)

                if let onPin {
                    Button(action: onPin) {
                        Image(systemName: isPinned ? "pin.fill" : "pin")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(isPinned ? Color("AppPrimary") : Color("AppTextSecondary"))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, 12)
            .padding(.vertical, 14)
        }
        .appCard(cornerRadius: 16, elevated: false)
        .opacity(isFading ? 0 : 1)
        .scaleEffect(isFading ? 0.96 : 1)
        .animation(.easeInOut(duration: 0.3), value: isFading)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture(perform: onToggle)
    }

    private var priorityStripe: some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(stripeColor)
            .frame(width: 4)
            .padding(.vertical, 10)
            .padding(.leading, 4)
    }

    private var stripeColor: Color {
        switch task.priority {
        case .high: return Color("AppPrimary")
        case .medium: return Color("AppAccent")
        case .low: return Color("AppTextSecondary").opacity(0.5)
        }
    }

    private var priorityTone: AppTag.TagTone {
        switch task.priority {
        case .high: return .primary
        case .medium: return .accent
        case .low: return .neutral
        }
    }

    private var formattedDueDate: String {
        task.dueDate.formatted(.dateTime.month(.abbreviated).day())
    }

    private var isOverdue: Bool {
        !task.isCompleted && task.dueDate < Calendar.current.startOfDay(for: Date())
    }

    private var hasMetaRow: Bool {
        task.recurrence != .none || focusMinutesToday > 0 || isPinned
    }
}

struct HabitCell: View {
    let habit: HabitItem
    let isCompleted: Bool
    var isDueToday: Bool = true
    var isPulsing: Bool = false
    var showNotTodayLabel: Bool = false
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(isCompleted ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.45), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    if isCompleted {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color("AppAccent"))
                            .frame(width: 28, height: 28)
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppBackground"))
                    }
                }
                .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .disabled(!isDueToday && showNotTodayLabel)

            AppIconBadge(icon: "flame.fill", size: 40, iconSize: .caption, style: isCompleted ? .success : .muted)

            VStack(alignment: .leading, spacing: 6) {
                Text(habit.name)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                HStack(spacing: 6) {
                    AppTag(text: habit.frequency.rawValue, tone: .neutral)
                    if showNotTodayLabel && !isDueToday {
                        AppTag(text: "Not today", tone: .neutral)
                    }
                }
            }

            Spacer(minLength: 0)

            VStack(spacing: 2) {
                Text("\(habit.streak)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color("AppPrimary"))
                Text("days")
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .appInsetPanel(cornerRadius: 12)
        }
        .padding(14)
        .overlay {
            if isPulsing {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color("AppAccent").opacity(0.14))
            }
        }
        .appCard(cornerRadius: 16, elevated: false)
        .animation(.easeInOut(duration: 0.35), value: isPulsing)
        .opacity(isDueToday || showNotTodayLabel ? 1 : 0.55)
    }
}

struct FocusBlockCell: View {
    let block: FocusBlockPlan
    var onStart: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            AppIconBadge(
                icon: block.isCompleted ? "checkmark.circle.fill" : "timer",
                size: 42,
                style: block.isCompleted ? .success : .primary
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(block.taskTitle)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                AppTag(text: "\(block.plannedMinutes) min block", icon: "hourglass", tone: .accent)
            }

            Spacer(minLength: 0)

            if !block.isCompleted, let onStart {
                Button(action: onStart) {
                    Text("Start")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppBackground"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .appGradientCapsule()
                }
            }

            if let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .appCard(cornerRadius: 16, elevated: false)
    }
}

struct FocusSessionCell: View {
    let session: FocusSessionRecord

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AppIconBadge(icon: "checkmark.seal.fill", size: 42, style: .success)

            VStack(alignment: .leading, spacing: 6) {
                Text("Worked on: \(session.taskTitle) — \(session.durationLabel)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Text(session.completedAt, format: .dateTime.month().day().hour().minute())
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))

                if !session.note.isEmpty {
                    Text(session.note)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appInsetPanel(cornerRadius: 10)
                }
            }
        }
        .padding(14)
        .appCard(cornerRadius: 16, elevated: false)
    }
}

struct FocusConfigCell: View {
    let title: String
    let value: String
    let icon: String
    var showEdit: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            if showEdit {
                HapticManager.lightTap()
                action()
            }
        } label: {
            HStack(spacing: 14) {
                AppIconBadge(icon: icon, size: 46, style: .primary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(value)
                        .font(.body.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Spacer()

                if showEdit {
                    Image(systemName: "slider.horizontal.3")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                        .frame(width: 44, height: 44)
                }
            }
            .padding(14)
            .appCard(cornerRadius: 16, elevated: false)
        }
        .buttonStyle(.plain)
        .disabled(!showEdit)
    }
}

struct SettingsRowCell: View {
    let title: String
    let icon: String
    var tint: Color = Color("AppPrimary")
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                AppIconBadge(icon: icon, size: 40, style: .primary)

                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

struct StatRowCell: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            AppIconBadge(icon: icon, size: 36, iconSize: .caption, style: .accent)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 4)
    }
}

struct AchievementCell: View {
    let achievement: AchievementDefinition
    let unlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        unlocked
                        ? LinearGradient(
                            colors: [Color("AppPrimary").opacity(0.35), Color("AppAccent").opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color("AppSurface"), Color("AppBackground")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)

                Image(systemName: achievement.iconName)
                    .font(.title3)
                    .foregroundStyle(unlocked ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.35))
            }

            Text(achievement.title)
                .font(.caption.weight(.bold))
                .foregroundStyle(unlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)

            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 150)
        .appCard(cornerRadius: 16, elevated: false)
        .overlay {
            if unlocked {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppGradients.unlockedGlow, lineWidth: 1.5)
            }
        }
        .opacity(unlocked ? 1 : 0.62)
    }
}

struct TaskPickerCell: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                AppIconBadge(icon: icon, size: 42, style: .primary)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(14)
            .appCard(cornerRadius: 16, elevated: false)
        }
        .buttonStyle(.plain)
    }
}

struct DailyProgressHeroCard: View {
    let progress: Int
    let focusMinutes: Int
    let sessions: Int
    let habitsDone: Int
    let habitsTotal: Int

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                AppProgressRing(progress: Double(progress) / 100.0, lineWidth: 9, size: 96)
                VStack(spacing: 0) {
                    Text("\(progress)")
                        .font(.title2.bold())
                        .foregroundStyle(Color("AppPrimary"))
                    Text("%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Daily Progress")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(progressSubtitle)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                HStack(spacing: 8) {
                    AppTag(text: "\(focusMinutes)m focus", icon: "timer", tone: .accent)
                    AppTag(text: "\(habitsDone)/\(habitsTotal) habits", icon: "checklist", tone: .primary)
                    AppTag(text: "\(sessions) sessions", icon: "bolt.fill", tone: .neutral)
                }
            }
        }
        .padding(18)
        .appCard()
    }

    private var progressSubtitle: String {
        if progress >= 100 {
            return "Perfect day achieved. Keep the momentum going."
        }
        if progress == 0 {
            return "Start with one task, habit, or focus block."
        }
        return "You're \(progress)% through today's plan."
    }
}

struct FocusTimerHeroCard: View {
    let timerDisplay: String
    let phaseLabel: String
    let linkedTaskLabel: String
    let progress: Double
    let isRunning: Bool
    let onPlayPause: () -> Void
    let onReset: () -> Void
    var onChangeTask: (() -> Void)? = nil
    var showTip: Bool = false

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                AppProgressRing(progress: progress, lineWidth: 8, size: 210)
                VStack(spacing: 8) {
                    Text(timerDisplay)
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .monospacedDigit()
                    AppTag(text: phaseLabel, tone: .accent)
                }
            }

            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "link.circle.fill")
                        .foregroundStyle(Color("AppPrimary"))
                    Text(linkedTaskLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                if let onChangeTask {
                    Button("Change Task", action: onChangeTask)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                }
            }

            if showTip {
                HStack(spacing: 10) {
                    AppIconBadge(icon: "lightbulb.fill", size: 34, style: .primary)
                    Text("Set your focus intervals and pick a task to begin.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appInsetPanel(cornerRadius: 12)
            }

            HStack(spacing: 12) {
                AppPrimaryButton(
                    title: isRunning ? "Pause" : "Start",
                    icon: isRunning ? "pause.fill" : "play.fill",
                    style: .secondary,
                    action: onPlayPause
                )
                AppPrimaryButton(title: "Reset", icon: "arrow.counterclockwise", style: .secondary, action: onReset)
            }
        }
        .padding(18)
        .appCard()
    }
}
