import SwiftUI

public struct DSIconButton: View {
    public enum Icon {
        case share
        case settings
        case more
    }

    private let icon: Icon
    private let action: () -> Void

    public init(_ icon: Icon, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            image
                .foregroundStyle(DesignSystem.Color.white)
        }
    }

    private var image: Image {
        switch icon {
        case .share: Image(asset: DesignSystemAsset.share2)
        case .settings: Image(asset: DesignSystemAsset.settings)
        case .more: Image(asset: DesignSystemAsset.ellipsisVertical)
        }
    }
}
