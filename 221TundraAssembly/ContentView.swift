import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppDataStore.shared

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .preferredColorScheme(.dark)
        .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
            // Environment object already reset; ensure UI refreshes
        }
    }
}

#Preview {
    ContentView()
}
