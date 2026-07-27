import SwiftUI

public struct DSRadioButton: View {
    @Environment(\.isEnabled) private var isEnabled
    @Binding private var isSelected: Bool
    private let title: String

    public init(_ title: String, isSelected: Binding<Bool>) {
        self.title = title
        _isSelected = isSelected
    }

    public var body: some View {
        Button {
            isSelected = true
        } label: {
            HStack(spacing: 8) {
                Image(asset: isSelected ? DesignSystemAsset.radioActive : DesignSystemAsset.radioInactive)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(foregroundColor)
                Text(title)
                    .momogoTypography(.mdMedium)
                    .foregroundStyle(foregroundColor)
                    .fixedSize()
            }
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        isEnabled ? DesignSystem.Color.gray50 : DesignSystem.Color.gray600
    }
}
