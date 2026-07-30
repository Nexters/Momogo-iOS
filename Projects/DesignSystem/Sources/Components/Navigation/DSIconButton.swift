import SwiftUI

public struct DSIconButton: View {
    public enum Icon {
        case share
        case settings
        case more
        case plus
    }

    /// `circular`은 nav bar 위에 얹히는 반투명 흰색 원형 배경 버튼.
    public enum Style {
        case plain
        case circular
    }

    private let icon: Icon
    private let style: Style
    private let action: () -> Void

    public init(_ icon: Icon, style: Style = .plain, action: @escaping () -> Void) {
        self.icon = icon
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            image
                .resizable()
                .scaledToFit()
                .foregroundStyle(DesignSystem.Color.white)
                .frame(width: iconSize, height: iconSize)
                .padding(padding)
                .background {
                    if style == .circular {
                        Circle().fill(DesignSystem.Color.white.opacity(0.5))
                    }
                }
                .frame(minWidth: 44, minHeight: 44)
        }
        .accessibilityLabel(accessibilityLabel)
    }

    private var image: Image {
        switch icon {
        case .share: Image(asset: DesignSystemAsset.share2)
        case .settings: Image(asset: DesignSystemAsset.settings)
        case .more: Image(asset: DesignSystemAsset.ellipsisVertical)
        case .plus: Image(asset: DesignSystemAsset.plus)
        }
    }

    private var accessibilityLabel: String {
        switch icon {
        case .share: "공유"
        case .settings: "설정"
        case .more: "더보기"
        case .plus: "추가"
        }
    }

    private var iconSize: CGFloat {
        style == .circular ? 20 : 24
    }

    private var padding: CGFloat {
        style == .circular ? 8 : 0
    }
}
