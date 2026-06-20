import StoreKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            AppScreenBackground {
                ScrollView {
                    VStack(spacing: 16) {
                        statsCard
                        settingsGroup
                        AppPrimaryButton(title: "Reset All Data", icon: "trash", style: .destructive) {
                            showResetAlert = true
                        }

                        Text("Version \(appVersion)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .appNavigationStyle()
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {
                    HapticManager.lightTap()
                }
                Button("Reset", role: .destructive) {
                    store.resetAllData()
                    NotificationCenter.default.post(name: .dataReset, object: nil)
                    HapticManager.warning()
                }
            } message: {
                Text("This will permanently delete all tasks, habits, focus data, and achievements.")
            }
        }
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Your Stats", icon: "chart.line.uptrend.xyaxis")

            StatRowCell(
                label: "Total Entries Created",
                value: "\(store.tasks.count + store.habits.count)",
                icon: "square.stack.3d.up.fill"
            )
            Divider().overlay(Color("AppTextSecondary").opacity(0.15))
            StatRowCell(
                label: "Total Minutes Used",
                value: "\(store.totalMinutesUsed)",
                icon: "clock.fill"
            )
            Divider().overlay(Color("AppTextSecondary").opacity(0.15))
            StatRowCell(
                label: "Current Streak",
                value: "\(store.currentAppUsageStreak) days",
                icon: "flame.fill"
            )
        }
        .padding(16)
        .appCard()
    }

    private var settingsGroup: some View {
        VStack(spacing: 0) {
            SettingsRowCell(title: "Rate Us", icon: "star.fill") {
                HapticManager.lightTap()
                rateApp()
            }

            Divider().overlay(Color("AppTextSecondary").opacity(0.12)).padding(.leading, 56)

            SettingsRowCell(title: "Privacy Policy", icon: "hand.raised.fill") {
                HapticManager.lightTap()
                openPrivacyPolicy()
            }

            Divider().overlay(Color("AppTextSecondary").opacity(0.12)).padding(.leading, 56)

            SettingsRowCell(title: "Terms of Use", icon: "doc.text.fill") {
                HapticManager.lightTap()
                openTermsOfUse()
            }
        }
        .appCard()
    }

    private func openPrivacyPolicy() {
        if let url = URL(string: AppExternalLink.privacyPolicy.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    private func openTermsOfUse() {
        if let url = URL(string: AppExternalLink.termsOfUse.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
