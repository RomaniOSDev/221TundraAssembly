import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakes: CGFloat = 2
    var animatableData: CGFloat

    init(animatableData: CGFloat = 0) {
        self.animatableData = animatableData
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * shakes),
                y: 0
            )
        )
    }
}
