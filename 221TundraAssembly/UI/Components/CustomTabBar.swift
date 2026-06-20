import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case home
    case tasks
    case focus
    case stats
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .tasks: return "Tasks"
        case .focus: return "Focus"
        case .stats: return "Stats"
        case .settings: return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .tasks: return "list.bullet.rectangle"
        case .focus: return "timer"
        case .stats: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    @State private var pressedTab: AppTab?

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppGradients.tabBarSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(AppGradients.cardHighlight)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppGradients.cardBorder, lineWidth: 1)
                )
        )
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.24), radius: 14, y: 7)
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }

    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            HapticManager.lightTap()
            SoundManager.playTick()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(AppGradients.primaryButton)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
                            )
                            .frame(width: 52, height: 30)
                    }
                    Image(systemName: tab.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? Color("AppBackground") : Color("AppTextSecondary"))
                }
                .frame(height: 30)

                Text(tab.title)
                    .font(.system(size: 10, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(isSelected ? Color("AppPrimary") : Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .scaleEffect(pressedTab == tab ? 0.94 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressedTab = tab }
                .onEnded { _ in pressedTab = nil }
        )
    }
}
