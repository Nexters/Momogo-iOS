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

    /// Figma 스펙: XL(기본, 54px)/L/S 3가지 사이즈
    public enum Size {
        case xl
        case large
        case small
    }

    @Environment(\.isEnabled) private var isEnabled

    private let kind: Kind
    private let tone: Tone
    private let size: Size
    private let showsLeadingIcon: Bool
    private let showsTrailingIcon: Bool
    private let isFullWidth: Bool

    public init(
        kind: Kind = .solid,
        tone: Tone = .primary,
        size: Size = .xl,
        showsLeadingIcon: Bool = false,
        showsTrailingIcon: Bool = false,
        isFullWidth: Bool = false
    ) {
        self.kind = kind
        self.tone = tone
        self.size = size
        self.showsLeadingIcon = showsLeadingIcon
        self.showsTrailingIcon = showsTrailingIcon
        self.isFullWidth = isFullWidth
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: iconGap) {
            if showsLeadingIcon {
                Image(asset: SharedDesignSystemAsset.iconChevronLeft)
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
            }
            configuration.label
                .momogoTypography(typography)
                .fixedSize()
            if showsTrailingIcon {
                Image(asset: SharedDesignSystemAsset.iconChevronRight)
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
            }
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .frame(maxWidth: isFullWidth ? .infinity : nil)
        .background(backgroundColor(isPressed: configuration.isPressed))
        .clipShape(Capsule())
        .overlay(borderOverlay)
    }

    private var typography: DesignSystem.Typography {
        switch size {
        case .xl: .lgSemistrong
        case .large: .mdSemistrong
        case .small: .xsSemistrong
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .xl: 32
        case .large: 24
        case .small: 16
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .xl: 14
        case .large: 12
        case .small: 8
        }
    }

    private var iconSize: CGFloat {
        size == .small ? 18 : 20
    }

    private var iconGap: CGFloat {
        size == .small ? 2 : 6
    }

    private var foregroundColor: Color {
        guard isEnabled else { return DesignSystem.Color.gray500 }
        switch kind {
        case .solid:
            return tone == .primary ? DesignSystem.Color.gray900 : DesignSystem.Color.gray50
        case .outlined, .text:
            return tone == .primary ? DesignSystem.Color.primary500 : DesignSystem.Color.gray50
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

public extension ButtonStyle where Self == DSButtonStyle {
    static func momogoButton(
        kind: DSButtonStyle.Kind = .solid,
        tone: DSButtonStyle.Tone = .primary,
        size: DSButtonStyle.Size = .xl,
        showsLeadingIcon: Bool = false,
        showsTrailingIcon: Bool = false,
        isFullWidth: Bool = false
    ) -> DSButtonStyle {
        DSButtonStyle(
            kind: kind,
            tone: tone,
            size: size,
            showsLeadingIcon: showsLeadingIcon,
            showsTrailingIcon: showsTrailingIcon,
            isFullWidth: isFullWidth
        )
    }
}
