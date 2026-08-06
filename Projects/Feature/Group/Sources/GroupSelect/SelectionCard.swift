import SwiftUI

import DesignSystem

struct SelectionCard: View {
    let icon: DesignSystemImages
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(asset: icon)
                    .resizable()
                    .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .momogoTypography(.lgSemistrong)
                        .foregroundStyle(DesignSystem.Color.gray50)
                    Text(subtitle)
                        .momogoTypography(.smMedium)
                        .foregroundStyle(DesignSystem.Color.gray300)
                }

                Spacer(minLength: 0)

                Image(asset: isSelected ? DesignSystemAsset.checkboxActive : DesignSystemAsset.checkboxInactive)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(DesignSystem.Color.gray50)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(isSelected ? DesignSystem.Color.white.opacity(0.08) : DesignSystem.Color.white.opacity(0.02))
            .clipShape(.rect(cornerRadius: DesignSystem.Radius.r16))
            .shadow(color: DesignSystem.Color.black.opacity(0.1), radius: 16, x: 0, y: 4)
            .contentShape(.rect(cornerRadius: DesignSystem.Radius.r16))
        }
        .buttonStyle(.plain)
        .animation(nil, value: isSelected)
    }
}
