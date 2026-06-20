import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView(selectedTab: $selectedTab)
                case .tasks:
                    TaskTrackerView()
                case .focus:
                    FocusHabitsContainerView()
                case .stats:
                    StatsView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selectedTab: $selectedTab)
        }
        .background(AppBackgroundView())
        .overlay {
            AchievementBannerContainer()
        }
        .preferredColorScheme(.dark)
    }
}

struct FocusHabitsContainerView: View {
    @State private var segment = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $segment) {
                Text("Focus").tag(0)
                Text("Habits").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .onChange(of: segment) { _ in
                HapticManager.lightTap()
            }

            if segment == 0 {
                FocusCycleView()
            } else {
                HabitLogView()
            }
        }
    }
}
