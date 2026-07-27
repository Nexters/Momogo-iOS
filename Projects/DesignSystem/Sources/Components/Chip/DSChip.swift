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

    public enum Size {
        case `default`
        case small
    }

    private let title: String
    private let tone: Tone
    private let size: Size
    private let showsLeadingIcon: Bool
    private let showsTrailingIcon: Bool

    public init(
        _ title: String,
        tone: Tone = .gray,
        size: Size = .default,
        showsLeadingIcon: Bool = true,
        showsTrailingIcon: Bool = true
    ) {
        self.title = title
        self.tone = tone
        self.size = size
        self.showsLeadingIcon = showsLeadingIcon
        self.showsTrailingIcon = showsTrailingIcon
    }

    public var body: some View {
        HStack(spacing: 2) {
            if showsLeadingIcon {
                Image(asset: DesignSystemAsset.chevronLeft)
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
            }
            Text(title)
                .momogoTypography(typography)
                .fixedSize()
            if showsTrailingIcon {
                Image(asset: DesignSystemAsset.chevronRight)
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
            }
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: radius))
    }

    private var typography: DesignSystem.Typography {
        size == .default ? .smMedium : .xsSemistrong
    }

    private var horizontalPadding: CGFloat {
        size == .default ? 12 : 8
    }

    private var verticalPadding: CGFloat {
        size == .default ? 6 : 4
    }

    private var radius: CGFloat {
        size == .default ? DesignSystem.Radius.r12 : DesignSystem.Radius.r10
    }

    private var iconSize: CGFloat {
        size == .default ? 18 : 16
    }

    private var foregroundColor: Color {
        tone == .gray ? DesignSystem.Color.gray50 : DesignSystem.Color.gray900
    }

    private var backgroundColor: Color {
        switch tone {
        case .gray: DesignSystem.Color.gray800
        case .primary: DesignSystem.Color.primary400
        case .secondary: DesignSystem.Color.secondary400
        case .green: DesignSystem.Color.systemGreen400
        case .blue: DesignSystem.Color.systemBlue400
        case .red: DesignSystem.Color.systemRed400
        }
    }
}
