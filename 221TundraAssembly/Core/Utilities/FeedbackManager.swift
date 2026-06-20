import AudioToolbox
import UIKit

enum HapticManager {
    static func lightTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func mediumTap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

enum SoundManager {
    static func playTick() {
        AudioServicesPlaySystemSound(1003)
    }

    static func playSuccess() {
        AudioServicesPlaySystemSound(1057)
    }

    static func playFocusComplete() {
        AudioServicesPlaySystemSound(1004)
    }

    static func playHabitComplete() {
        AudioServicesPlaySystemSound(1104)
    }

    static func playVibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
