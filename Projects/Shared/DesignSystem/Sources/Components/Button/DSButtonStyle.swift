import SwiftUI

public struct DSButtonStyle: ButtonStyle {
    public enum Kind {
        case solid
        case outlined
        case text
    }

    public enum Tone {
        case primary
        case gray
    }

    @Environment(\.isEnabled) private var isEnabled

    private let kind: Kind
    private let tone: Tone
    private let isFullWidth: Bool

    public init(kind: Kind = .solid, tone: Tone = .primary, isFullWidth: Bool = true) {
        self.kind = kind
        self.tone = tone
        self.isFullWidth = isFullWidth
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .momogoTypography(.mdSemistrong)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 20)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: 44)
            .background(backgroundColor(isPressed: configuration.isPressed))
            .clipShape(Capsule())
            .overlay(borderOverlay)
    }

    private var foregroundColor: Color {
        guard isEnabled else { return DesignSystem.Color.gray500 }
        switch kind {
        case .solid:
            return tone == .primary ? DesignSystem.Color.gray900 : DesignSystem.Color.white
        case .outlined, .text:
            return tone == .primary ? DesignSystem.Color.primary500 : DesignSystem.Color.white
        }
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        guard isEnabled else {
            return kind == .solid ? DesignSystem.Color.gray800 : .clear
        }
        switch kind {
        case .solid:
            let base = tone == .primary ? DesignSystem.Color.primary500 : DesignSystem.Color.gray700
            let pressed = tone == .primary ? DesignSystem.Color.primary600 : DesignSystem.Color.gray800
            return isPressed ? pressed : base
        case .outlined:
            guard isPressed else { return .clear }
            return tone == .primary
                ? DesignSystem.Color.primary500.opacity(0.12)
                : DesignSystem.Color.white.opacity(0.08)
        case .text:
            return .clear
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if kind == .outlined {
            let color = isEnabled
                ? (tone == .primary ? DesignSystem.Color.primary500 : DesignSystem.Color.gray600)
                : DesignSystem.Color.gray700
            Capsule().stroke(color)
        }
    }
}

extension ButtonStyle where Self == DSButtonStyle {
    public static func momogoButton(
        kind: DSButtonStyle.Kind = .solid,
        tone: DSButtonStyle.Tone = .primary,
        isFullWidth: Bool = true
    ) -> DSButtonStyle {
        DSButtonStyle(kind: kind, tone: tone, isFullWidth: true)
    }
}
