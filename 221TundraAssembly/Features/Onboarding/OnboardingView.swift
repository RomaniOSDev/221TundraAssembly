import SwiftUI

private struct OnboardingPage {
    let headline: String
    let description: String
    let icon: String
    let features: [String]
    let illustration: AppIllustration
}

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            headline: "Boost Productivity",
            description: "Plan your day, stay focused, and build habits that stick — all in one calm workspace.",
            icon: "bolt.fill",
            features: ["Tasks", "Focus", "Habits"],
            illustration: .focus
        ),
        OnboardingPage(
            headline: "Organize Tasks",
            description: "Capture ideas, set priorities, and track progress with categories, due dates, and focus time.",
            icon: "list.bullet.rectangle",
            features: ["Priority", "Categories", "Recurring"],
            illustration: .tasks
        ),
        OnboardingPage(
            headline: "Start Your Journey",
            description: "Pin today's plan, run focus sessions, and watch your streaks grow in weekly insights.",
            icon: "flag.fill",
            features: ["Daily Plan", "Streaks", "Insights"],
            illustration: .habits
        )
    ]

    var body: some View {
        AppScreenBackground {
            VStack(spacing: 0) {
                onboardingHeader
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        onboardingPageView(pages[index], index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                pageIndicator
                    .padding(.bottom, 20)

                AppPrimaryButton(
                    title: currentPage < pages.count - 1 ? "Continue" : "Get Started",
                    icon: currentPage < pages.count - 1 ? "arrow.right" : "checkmark"
                ) {
                    SoundManager.playTick()
                    if currentPage < pages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    } else {
                        store.completeOnboarding()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
    }

    private var onboardingHeader: some View {
        HStack(spacing: 12) {
            AppTag(
                text: "Step \(currentPage + 1) of \(pages.count)",
                icon: "sparkles",
                tone: .primary
            )

            Spacer()

            AppIconBadge(
                icon: pages[currentPage].icon,
                size: 38,
                iconSize: .caption,
                style: .accent
            )
        }
        .animation(.easeInOut(duration: 0.25), value: currentPage)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentPage
                        ? AnyShapeStyle(AppGradients.primaryButton)
                        : AnyShapeStyle(Color("AppTextSecondary").opacity(0.22))
                    )
                    .overlay {
                        if index == currentPage {
                            Capsule()
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        }
                    }
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.72), value: currentPage)
            }
        }
    }

    private func onboardingPageView(_ page: OnboardingPage, index: Int) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            VStack(spacing: 20) {
                AppIllustrationImage(illustration: page.illustration)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(spacing: 16) {
                    Text(page.headline)
                        .font(.title.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Text(page.description)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 8) {
                        ForEach(page.features, id: \.self) { feature in
                            AppTag(text: feature, tone: .accent)
                        }
                    }
                }
            }
            .padding(18)
            .appCard(cornerRadius: 22, elevated: true)
            .padding(.horizontal, 20)
            .id(index)
            .modifier(OnboardingAppearModifier())

            Spacer(minLength: 12)
        }
    }
}

private struct OnboardingAppearModifier: ViewModifier {
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(appeared ? 1.0 : 0.94)
            .opacity(appeared ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                    appeared = true
                }
            }
    }
}
