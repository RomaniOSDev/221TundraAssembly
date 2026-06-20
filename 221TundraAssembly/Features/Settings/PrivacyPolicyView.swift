import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    private let policyText: String = {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return "# Privacy Policy\nThis app does NOT collect, store, or transmit any personal data."
        }
        return text
    }()

    var body: some View {
        NavigationStack {
            AppSheetBackground {
                ScrollView {
                    Group {
                        if let attributed = try? AttributedString(
                            markdown: policyText,
                            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
                        ) {
                            Text(attributed)
                        } else {
                            Text(policyText)
                        }
                    }
                    .foregroundStyle(Color("AppTextPrimary"))
                    .tint(Color("AppPrimary"))
                    .padding(16)
                    .appCard(cornerRadius: 16, elevated: false)
                    .padding(16)
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationStyle()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.lightTap()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            }
        }
    }
}
