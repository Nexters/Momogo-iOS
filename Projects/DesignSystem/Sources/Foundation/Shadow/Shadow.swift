import SwiftUI

public extension DesignSystem {
    enum Shadow {
        public static let color = DesignSystem.Color.black.opacity(0.32)
        public static let radius: CGFloat = 32
        public static let x: CGFloat = 0
        public static let y: CGFloat = 8
    }
}

public extension View {
    func momogoShadow() -> some View {
        shadow(
            color: DesignSystem.Shadow.color,
            radius: DesignSystem.Shadow.radius,
            x: DesignSystem.Shadow.x,
            y: DesignSystem.Shadow.y
        )
    }
}
