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

        private var fontConvertible: DesignSystemFontConvertible {
            switch self {
            case .heading32, .heading26, .heading24, .heading20:
                DesignSystemFontFamily.WantedSans.bold
            case .xlSemistrong, .lgSemistrong, .mdSemistrong, .smSemistrong, .xsSemistrong:
                DesignSystemFontFamily.WantedSans.semiBold
            case .xlMedium, .lgMedium, .mdMedium, .smMedium, .xsMedium:
                DesignSystemFontFamily.WantedSans.medium
            }
        }

        public var font: Font {
            fontConvertible.swiftUIFont(size: size)
        }

        // Figma 스펙: letterSpacing -2%
        public var tracking: CGFloat { size * -0.02 }

        // Figma 스펙: lineHeight 150%. `lineSpacing`은 폰트 자체의 줄간격 위에 더해지는 값이라,
        // 목표 줄간격(size * 1.5)에서 폰트가 이미 가진 자연 줄간격을 뺀 만큼만 추가한다.
        var multilineLineSpacing: CGFloat {
            max(0, size * 1.5 - fontConvertible.font(size: size).lineHeight)
        }
    }
}

public extension View {
    func momogoTypography(_ style: DesignSystem.Typography) -> some View {
        font(style.font)
            .tracking(style.tracking)
    }

    /// 줄바꿈이 있는 여러 줄 텍스트에 Figma 스펙의 150% 줄간격을 함께 적용한다.
    /// 단일 줄 텍스트(버튼/칩 등 높이가 고정된 컴포넌트)에는 `momogoTypography(_:)`만 사용한다.
    func momogoMultilineTypography(_ style: DesignSystem.Typography) -> some View {
        momogoTypography(style)
            .lineSpacing(style.multilineLineSpacing)
    }
}
