import Foundation

enum AppExternalLink: String {
    case privacyPolicy = "https://tundraassembly221.site/privacy/259"
    case termsOfUse = "https://tundraassembly221.site/terms/259"

    var url: URL? {
        URL(string: rawValue)
    }
}
