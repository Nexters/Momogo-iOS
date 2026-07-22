import SwiftUI

public struct DSChip: View {
    public enum Tone {
        case gray
        case primary
        case secondary
        case green
        case blue
        case red
    }

    private let title: String
    private let tone: Tone

    public init(_ title: String, tone: Tone = .gray) {
        self.title = title
        self.tone = tone
    }

    public var body: some View {
        Text(title)
            .momogoTypography(.smMedium)
            .foregroundStyle(DesignSystem.Color.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch tone {
        case .gray: return DesignSystem.Color.gray700
        case .primary: return DesignSystem.Color.primary500
        case .secondary: return DesignSystem.Color.secondary500
        case .green: return DesignSystem.Color.systemGreen500
        case .blue: return DesignSystem.Color.systemBlue500
        case .red: return DesignSystem.Color.systemRed500
        }
    }
}
