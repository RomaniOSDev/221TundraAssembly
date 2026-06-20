import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color("AppBackground"),
                    Color("AppSurface").opacity(0.78),
                    Color("AppBackground").opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            LinearGradient(
                colors: [
                    Color("AppPrimary").opacity(0.07),
                    Color.clear,
                    Color("AppAccent").opacity(0.05)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )

            RadialGradient(
                colors: [Color("AppPrimary").opacity(0.10), Color.clear],
                center: .topTrailing,
                startRadius: 24,
                endRadius: 340
            )

            RadialGradient(
                colors: [Color("AppAccent").opacity(0.08), Color.clear],
                center: .bottomLeading,
                startRadius: 16,
                endRadius: 300
            )
        }
        .drawingGroup(opaque: false)
        .ignoresSafeArea()
    }
}
