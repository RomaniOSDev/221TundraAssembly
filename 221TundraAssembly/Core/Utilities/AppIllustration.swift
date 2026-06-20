import SwiftUI

enum AppIllustration: String {
    case tasks = "IllustrationTasks"
    case focus = "IllustrationFocus"
    case habits = "IllustrationHabits"

    var imageName: String { rawValue }
}

struct AppIllustrationImage: View {
    let illustration: AppIllustration

    var body: some View {
        Image(illustration.imageName)
            .resizable()
            .scaledToFit()
            .accessibilityHidden(true)
    }
}
