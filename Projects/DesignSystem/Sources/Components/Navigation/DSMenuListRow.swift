import SwiftUI

/// 설정 화면 등에서 쓰이는 리스트 메뉴 행. Figma `Menu/List/Button` 컴포넌트에 대응한다.
public struct DSMenuListRow: View {
    private let icon: DesignSystemImages
    private let title: String
    private let action: () -> Void

    public init(icon: DesignSystemImages, title: String, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(asset: icon)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(DesignSystem.Color.gray200)
                        .frame(width: 20, height: 20)
                    Text(title)
                        .momogoTypography(.mdMedium)
                        .foregroundStyle(DesignSystem.Color.white)
                }
                Spacer(minLength: 0)
                Image(asset: DesignSystemAsset.chevronRight)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(DesignSystem.Color.gray700)
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(DesignSystem.Color.gray800)
                .frame(height: 1)
        }
    }
}
