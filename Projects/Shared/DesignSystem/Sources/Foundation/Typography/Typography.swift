import SwiftUI

public extension DesignSystem {
    enum Typography {
        case heading32
        case heading26
        case heading24
        case heading20
        case xlSemistrong
        case xlMedium
        case lgSemistrong
        case lgMedium
        case mdSemistrong
        case mdMedium
        case smSemistrong
        case smMedium
        case xsSemistrong
        case xsMedium

        public var size: CGFloat {
            switch self {
            case .heading32: 32
            case .heading26: 26
            case .heading24: 24
            case .heading20: 20
            case .xlSemistrong, .xlMedium: 20
            case .lgSemistrong, .lgMedium: 17
            case .mdSemistrong, .mdMedium: 16
            case .smSemistrong, .smMedium: 14
            case .xsSemistrong, .xsMedium: 12
            }
        }

        public var weight: Font.Weight {
            switch self {
            case .heading32, .heading26, .heading24, .heading20:
                .bold
            case .xlSemistrong, .lgSemistrong, .mdSemistrong, .smSemistrong, .xsSemistrong:
                .semibold
            case .xlMedium, .lgMedium, .mdMedium, .smMedium, .xsMedium:
                .medium
            }
        }

        public var font: Font {
            .custom("Wanted Sans", size: size).weight(weight)
        }

        // Figma 스펙: lineHeight 150%, letterSpacing -2% — SwiftUI Font에는 line-height API가 없어 근사치로 적용
        public var lineHeight: CGFloat { size * 1.5 }
        public var tracking: CGFloat { size * -0.02 }
    }
}

public extension View {
    func momogoTypography(_ style: DesignSystem.Typography) -> some View {
        font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineHeight - style.size)
    }
}
