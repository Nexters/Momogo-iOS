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

    /// Figma 스펙: XL(기본, 54px)/L/M/S 4가지 사이즈
    public enum Size {
        case xl
        case large
        case medium
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
            leadingIconSlot
            configuration.label
                .momogoTypography(typography)
                .fixedSize()
                .frame(maxWidth: isFullWidth ? .infinity : nil)
            trailingIconSlot
        }
        .foregroundStyle(foregroundColor(isPressed: configuration.isPressed))
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .frame(maxWidth: isFullWidth ? .infinity : nil, minHeight: fixedHeight)
        .background(backgroundColor(isPressed: configuration.isPressed))
        .clipShape(.capsule)
        .overlay { borderOverlay(isPressed: configuration.isPressed) }
    }

    /// 아이콘이 한쪽에만 있어도 타이틀이 항상 가운데 오도록, 반대쪽에 같은 크기의
    /// 투명한 자리를 남겨 좌우를 대칭으로 맞춘다.
    private var showsAnyIcon: Bool { showsLeadingIcon || showsTrailingIcon }

    @ViewBuilder
    private var leadingIconSlot: some View {
        if showsAnyIcon {
            iconOrPlaceholder(DesignSystemAsset.chevronLeft, isVisible: showsLeadingIcon)
        }
    }

    @ViewBuilder
    private var trailingIconSlot: some View {
        if showsAnyIcon {
            iconOrPlaceholder(DesignSystemAsset.chevronRight, isVisible: showsTrailingIcon)
        }
    }

    @ViewBuilder
    private func iconOrPlaceholder(_ asset: DesignSystemImages, isVisible: Bool) -> some View {
        if isVisible {
            Image(asset: asset)
                .resizable()
                .frame(width: iconSize, height: iconSize)
        } else {
            Color.clear
                .frame(width: iconSize, height: iconSize)
        }
    }

    private var typography: DesignSystem.Typography {
        switch size {
        case .xl: .lgSemistrong
        case .large: .mdSemistrong
        case .medium: .smMedium
        case .small: .xsSemistrong
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .xl: 32
        case .large: 24
        case .medium: 20
        case .small: 16
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .xl: 14
        case .large: 12
        case .medium: 10
        case .small: 8
        }
    }

    /// Figma 실측 고정 높이(XL=54px, M=48px). 패딩만으로는 스펙 높이에 못 미쳐 별도로 고정한다.
    private var fixedHeight: CGFloat? {
        switch size {
        case .xl: 54
        case .medium: 48
        case .large, .small: nil
        }
    }

    private var iconSize: CGFloat {
        size == .small ? 18 : 20
    }

    private var iconGap: CGFloat {
        size == .small ? 2 : 6
    }

    private func foregroundColor(isPressed: Bool) -> Color {
        guard isEnabled else {
            return kind == .solid && tone == .gray ? DesignSystem.Color.gray700 : DesignSystem.Color.gray600
        }
        switch kind {
        case .solid:
            return tone == .primary ? DesignSystem.Color.gray900 : DesignSystem.Color.gray50
        case .outlined:
            guard tone == .primary else { return DesignSystem.Color.gray50 }
            return isPressed ? DesignSystem.Color.primary400 : DesignSystem.Color.primary500
        case .text:
            return tone == .primary ? DesignSystem.Color.primary500 : DesignSystem.Color.gray50
        }
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        guard isEnabled else {
            return kind == .solid ? DesignSystem.Color.white.opacity(0.04) : .clear
        }
        switch kind {
        case .solid:
            let base = tone == .primary ? DesignSystem.Color.primary500 : DesignSystem.Color.gray900
            let pressed = tone == .primary ? DesignSystem.Color.primary400 : DesignSystem.Color.gray700
            return isPressed ? pressed : base
        case .outlined:
            return isPressed ? DesignSystem.Color.white.opacity(0.04) : .clear
        case .text:
            return .clear
        }
    }

    @ViewBuilder
    private func borderOverlay(isPressed: Bool) -> some View {
        if kind == .outlined {
            let color: Color = if !isEnabled {
                DesignSystem.Color.gray700
            } else if tone == .primary {
                isPressed ? DesignSystem.Color.primary400 : DesignSystem.Color.primary500
            } else {
                DesignSystem.Color.gray700
            }
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
