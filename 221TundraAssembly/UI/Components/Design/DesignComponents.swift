import SwiftUI

struct AppCardStyle: ViewModifier {
    var cornerRadius: CGFloat = 18
    var elevated: Bool = true

    func body(content: Content) -> some View {
        content
            .background(AppCardBackground(cornerRadius: cornerRadius))
            .compositingGroup()
            .shadow(
                color: elevated ? Color.black.opacity(0.20) : Color.clear,
                radius: elevated ? 10 : 0,
                y: elevated ? 5 : 0
            )
    }
}

extension View {
    func appCard(cornerRadius: CGFloat = 18, elevated: Bool = true) -> some View {
        modifier(AppCardStyle(cornerRadius: cornerRadius, elevated: elevated))
    }

    func appInsetPanel(cornerRadius: CGFloat = 12) -> some View {
        background(AppInsetPanelBackground(cornerRadius: cornerRadius))
    }

    func appGradientCapsule() -> some View {
        background(AppGradientCapsuleBackground())
    }
}

struct AppIconBadge: View {
    let icon: String
    var size: CGFloat = 44
    var iconSize: Font = .body
    var style: BadgeStyle = .primary

    enum BadgeStyle {
        case primary, accent, muted, success
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundGradient)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .frame(width: size, height: size)
            Image(systemName: icon)
                .font(iconSize.weight(.semibold))
                .foregroundStyle(foregroundColor)
        }
    }

    private var backgroundGradient: LinearGradient {
        switch style {
        case .primary: return AppGradients.primaryBadge
        case .accent: return AppGradients.accentBadge
        case .muted: return AppGradients.mutedBadge
        case .success: return AppGradients.successBadge
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return Color("AppPrimary")
        case .accent: return Color("AppAccent")
        case .muted: return Color("AppTextSecondary")
        case .success: return Color("AppAccent")
        }
    }
}

struct AppSectionHeader: View {
    let title: String
    var icon: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 10) {
            if let icon {
                AppIconBadge(icon: icon, size: 32, iconSize: .caption, style: .primary)
            }

            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer()

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.caption.weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color("AppBackground"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .appGradientCapsule()
                }
            }
        }
    }
}

struct AppEmptyStateView: View {
    let icon: String
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(spacing: 14) {
            AppIconBadge(icon: icon, size: 64, iconSize: .title2, style: .muted)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)

            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .appCard()
    }
}

struct AppSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color("AppPrimary"))
            TextField(placeholder, text: $text)
                .foregroundStyle(Color("AppTextPrimary"))
            if !text.isEmpty {
                Button {
                    HapticManager.lightTap()
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .appInsetPanel(cornerRadius: 14)
    }
}

struct AppFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(isSelected ? Color("AppBackground") : Color("AppTextSecondary"))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(AppGradients.primaryButton)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
                            )
                    } else {
                        Capsule()
                            .fill(AppGradients.insetPanel)
                            .overlay(
                                Capsule()
                                    .stroke(Color("AppPrimary").opacity(0.16), lineWidth: 1)
                            )
                    }
                }
        }
    }
}

struct AppMetricTile: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            AppIconBadge(icon: icon, size: 34, iconSize: .caption, style: .accent)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .appInsetPanel(cornerRadius: 14)
    }
}

struct AppProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 10
    var size: CGFloat = 120

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AppBackground").opacity(0.85), lineWidth: lineWidth + 2)
            Circle()
                .stroke(Color("AppTextSecondary").opacity(0.14), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    AngularGradient(
                        colors: [Color("AppPrimary"), Color("AppAccent"), Color("AppPrimary")],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.35), value: progress)
        }
        .frame(width: size, height: size)
    }
}

struct AppPrimaryButton: View {
    let title: String
    var icon: String? = nil
    var style: ButtonVariant = .primary
    let action: () -> Void

    enum ButtonVariant {
        case primary, secondary, destructive
    }

    var body: some View {
        Button {
            HapticManager.lightTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.headline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background { buttonBackground }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(borderColor, lineWidth: style == .secondary ? 1 : 0)
            )
            .compositingGroup()
            .shadow(
                color: style == .primary ? Color("AppPrimary").opacity(0.28) : Color.clear,
                radius: style == .primary ? 8 : 0,
                y: style == .primary ? 4 : 0
            )
        }
    }

    @ViewBuilder
    private var buttonBackground: some View {
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppGradients.primaryButton)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppGradients.cardHighlight)
                )
        case .secondary:
            AppCardBackground(cornerRadius: 16)
        case .destructive:
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppGradients.insetPanel)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.red.opacity(0.28), lineWidth: 1)
                )
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return Color("AppBackground")
        case .secondary: return Color("AppTextPrimary")
        case .destructive: return Color.red.opacity(0.9)
        }
    }

    private var borderColor: Color {
        switch style {
        case .secondary: return Color("AppPrimary").opacity(0.2)
        default: return Color.clear
        }
    }
}

struct AppFloatingActionButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.lightTap()
            SoundManager.playTick()
            action()
        } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundStyle(Color("AppBackground"))
                .frame(width: 58, height: 58)
                .background(
                    Circle()
                        .fill(AppGradients.primaryButton)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                )
                .compositingGroup()
                .shadow(color: Color("AppPrimary").opacity(0.32), radius: 10, y: 5)
        }
    }
}

struct AppTag: View {
    let text: String
    var icon: String? = nil
    var tone: TagTone = .neutral

    enum TagTone {
        case neutral, primary, accent, warning
    }

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption2)
            }
            Text(text)
                .font(.caption2.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [foreground.opacity(0.20), foreground.opacity(0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Capsule()
                        .stroke(foreground.opacity(0.12), lineWidth: 0.5)
                )
        )
    }

    private var foreground: Color {
        switch tone {
        case .neutral: return Color("AppTextSecondary")
        case .primary: return Color("AppPrimary")
        case .accent: return Color("AppAccent")
        case .warning: return Color("AppPrimary")
        }
    }
}

struct AppListSectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(Color("AppTextSecondary"))
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 2)
    }
}

struct AppSheetBackground<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            AppBackgroundView()
            content
        }
    }
}

struct AppScreenBackground<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            AppBackgroundView()
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension View {
    func appScreenBackground() -> some View {
        AppScreenBackground {
            self
        }
    }

    func appNavigationStyle() -> some View {
        toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
    }
}

struct AppFormCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppTextSecondary"))
            content
        }
        .padding(16)
        .appCard()
    }
}
