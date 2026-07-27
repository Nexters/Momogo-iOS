import SwiftUI

public struct DSTooltip: View {
    public enum ArrowDirection {
        case up
        case down
    }

    private let text: String
    private let arrowDirection: ArrowDirection

    public init(_ text: String, arrowDirection: ArrowDirection = .down) {
        self.text = text
        self.arrowDirection = arrowDirection
    }

    public var body: some View {
        VStack(spacing: 0) {
            if arrowDirection == .up {
                arrow
            }
            Text(text)
                .momogoTypography(.xsMedium)
                .foregroundStyle(DesignSystem.Color.gray50)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(DesignSystem.Color.gray700)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r12))
            if arrowDirection == .down {
                arrow
            }
        }
    }

    private var arrow: some View {
        DSTooltipArrow()
            .fill(DesignSystem.Color.gray700)
            .frame(width: 12, height: 6)
            .rotationEffect(.degrees(arrowDirection == .down ? 180 : 0))
    }
}

private struct DSTooltipArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

public extension View {
    /// Figma 스펙: Tooltip은 3초 후 자동으로 사라짐
    func momogoTooltip(
        isPresented: Binding<Bool>,
        text: String,
        arrowDirection: DSTooltip.ArrowDirection = .down
    ) -> some View {
        overlay(alignment: arrowDirection == .down ? .top : .bottom) {
            if isPresented.wrappedValue {
                DSTooltip(text, arrowDirection: arrowDirection)
                    .transition(.opacity)
                    .task {
                        try? await Task.sleep(for: .seconds(3))
                        isPresented.wrappedValue = false
                    }
            }
        }
    }
}
