import SwiftUI

struct AchievementBannerView: View {
    let achievement: AchievementDefinition
    let onDismiss: () -> Void

    @State private var offset: CGFloat = -120

    var body: some View {
        HStack(spacing: 12) {
            AppIconBadge(icon: achievement.iconName, size: 42, style: .success)

            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(achievement.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .appCard(cornerRadius: 16, elevated: true)
        .padding(.horizontal, 16)
        .offset(y: offset)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    offset = -120
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    onDismiss()
                }
            }
        }
    }
}

struct AchievementBannerContainer: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var currentBanner: AchievementDefinition?

    var body: some View {
        VStack {
            if let banner = currentBanner {
                AchievementBannerView(achievement: banner) {
                    currentBanner = nil
                    showNextBanner()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .onChange(of: store.pendingAchievementBanners.count) { _ in
            scheduleNextBanner()
        }
        .onAppear {
            scheduleNextBanner()
        }
    }

    private func scheduleNextBanner() {
        guard currentBanner == nil else { return }
        Task { @MainActor in
            showNextBanner()
        }
    }

    private func showNextBanner() {
        guard currentBanner == nil else { return }
        if let next = store.dequeueAchievementBanner() {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                currentBanner = next
            }
        }
    }
}
