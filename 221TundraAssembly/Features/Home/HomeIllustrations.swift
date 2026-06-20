import SwiftUI

struct HomeDeskIllustration: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            let deskRect = CGRect(x: w * 0.08, y: h * 0.58, width: w * 0.84, height: h * 0.22)
            context.fill(Path(roundedRect: deskRect, cornerRadius: 8), with: .color(Color("AppSurface")))

            let screenRect = CGRect(x: w * 0.18, y: h * 0.22, width: w * 0.38, height: h * 0.34)
            context.fill(Path(roundedRect: screenRect, cornerRadius: 6), with: .color(Color("AppBackground")))
            context.stroke(Path(roundedRect: screenRect, cornerRadius: 6), with: .color(Color("AppPrimary").opacity(0.6)), lineWidth: 2)

            var linePath = Path()
            linePath.move(to: CGPoint(x: screenRect.minX + 12, y: screenRect.minY + 16))
            linePath.addLine(to: CGPoint(x: screenRect.maxX - 12, y: screenRect.minY + 16))
            context.stroke(linePath, with: .color(Color("AppAccent")), lineWidth: 3)

            let cupRect = CGRect(x: w * 0.68, y: h * 0.48, width: w * 0.14, height: h * 0.16)
            context.fill(Path(roundedRect: cupRect, cornerRadius: 4), with: .color(Color("AppPrimary").opacity(0.85)))

            let plantRect = CGRect(x: w * 0.74, y: h * 0.18, width: w * 0.16, height: h * 0.22)
            context.fill(Path(ellipseIn: plantRect), with: .color(Color("AppAccent").opacity(0.45)))
            context.fill(Path(ellipseIn: plantRect.insetBy(dx: 8, dy: 10)), with: .color(Color("AppPrimary").opacity(0.35)))

            let lampRect = CGRect(x: w * 0.06, y: h * 0.12, width: w * 0.12, height: h * 0.12)
            context.fill(Path(ellipseIn: lampRect), with: .color(Color("AppPrimary")))
        }
        .frame(height: 120)
    }
}

struct HomeFocusWaveIllustration: View {
    var body: some View {
        Canvas { context, size in
            for index in 0..<4 {
                let amplitude = size.height * (0.12 + Double(index) * 0.06)
                let y = size.height * 0.55 + CGFloat(index) * 8
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                for x in stride(from: 0.0, through: size.width, by: 4) {
                    let angle = (x / size.width) * .pi * 2
                    let offset = sin(angle + Double(index)) * amplitude
                    path.addLine(to: CGPoint(x: x, y: y + offset))
                }
                let opacity = 0.25 + Double(index) * 0.15
                context.stroke(
                    path,
                    with: .color(index % 2 == 0 ? Color("AppPrimary").opacity(opacity) : Color("AppAccent").opacity(opacity)),
                    lineWidth: 2
                )
            }

            let center = CGPoint(x: size.width * 0.72, y: size.height * 0.42)
            context.fill(Path(ellipseIn: CGRect(x: center.x - 18, y: center.y - 18, width: 36, height: 36)), with: .color(Color("AppPrimary")))
            context.fill(Path(ellipseIn: CGRect(x: center.x - 10, y: center.y - 10, width: 20, height: 20)), with: .color(Color("AppBackground")))
        }
        .frame(height: 72)
    }
}

struct HomeHabitIllustration: View {
    let progress: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color("AppBackground").opacity(0.55))
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(row < Int(progress * 3) ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.25))
                            .frame(width: 14, height: 14)
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color("AppTextSecondary").opacity(0.2))
                            .frame(width: CGFloat(56 - row * 8), height: 6)
                    }
                }
            }
            .padding(12)
        }
        .frame(width: 92, height: 92)
    }
}

struct HomeWeeklyIllustration: View {
    let values: [Int]

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(Array(values.enumerated()), id: \.offset) { item in
                let maxVal = max(values.max() ?? 1, 1)
                let height = max(8, CGFloat(item.element) / CGFloat(maxVal) * 48)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color("AppPrimary"), Color("AppAccent")],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 10, height: height)
            }
        }
        .frame(height: 56)
    }
}

struct HomeMotivationIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color("AppPrimary").opacity(0.15))
                .frame(width: 90, height: 90)
                .offset(x: 30, y: -10)

            Path { path in
                path.move(to: CGPoint(x: 20, y: 80))
                path.addQuadCurve(to: CGPoint(x: 120, y: 30), control: CGPoint(x: 50, y: 10))
            }
            .stroke(Color("AppAccent"), style: StrokeStyle(lineWidth: 3, lineCap: .round))

            Image(systemName: "flag.checkered")
                .font(.title2)
                .foregroundStyle(Color("AppPrimary"))
                .offset(x: 48, y: -18)

            Image(systemName: "figure.walk")
                .font(.title3)
                .foregroundStyle(Color("AppTextPrimary"))
                .offset(x: -40, y: 20)
        }
        .frame(width: 140, height: 90)
    }
}
