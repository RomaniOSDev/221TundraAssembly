import SwiftUI

enum AppGradients {
    static var surfaceFill: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppSurface").opacity(0.94),
                Color("AppBackground").opacity(0.62)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var insetPanel: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppBackground").opacity(0.72),
                Color("AppBackground").opacity(0.38)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardBorder: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppPrimary").opacity(0.28),
                Color("AppAccent").opacity(0.12),
                Color("AppTextSecondary").opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardHighlight: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.10),
                Color.white.opacity(0.02),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .center
        )
    }

    static var primaryButton: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryBadge: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppPrimary").opacity(0.34),
                Color("AppPrimary").opacity(0.10)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentBadge: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppAccent").opacity(0.34),
                Color("AppAccent").opacity(0.10)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var mutedBadge: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppTextSecondary").opacity(0.22),
                Color("AppTextSecondary").opacity(0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var successBadge: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppAccent").opacity(0.38),
                Color("AppPrimary").opacity(0.14)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var tabBarSurface: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface").opacity(0.98),
                Color("AppSurface").opacity(0.88),
                Color("AppBackground").opacity(0.75)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var unlockedGlow: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppPrimary").opacity(0.55),
                Color("AppAccent").opacity(0.28),
                Color("AppPrimary").opacity(0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct AppCardBackground: View {
    var cornerRadius: CGFloat = 18
    var showHighlight: Bool = true

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppGradients.surfaceFill)
            .overlay {
                if showHighlight {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppGradients.cardHighlight)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppGradients.cardBorder, lineWidth: 1)
            )
    }
}

struct AppInsetPanelBackground: View {
    var cornerRadius: CGFloat = 12

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppGradients.insetPanel)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color("AppTextSecondary").opacity(0.10), lineWidth: 1)
            )
    }
}

struct AppGradientCapsuleBackground: View {
    var body: some View {
        Capsule()
            .fill(AppGradients.primaryButton)
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
    }
}
