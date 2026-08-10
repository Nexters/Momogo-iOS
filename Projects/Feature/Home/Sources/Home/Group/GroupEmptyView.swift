import SwiftUI

import DesignSystem

struct GroupEmptyView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(asset: DesignSystemAsset.illustGroupEmpty)
                .resizable()
                .scaledToFit()
                .frame(width: 111.65, height: 125.77)
                .frame(width: 163, height: 163)
                .accessibilityHidden(true)

            Text("아직 속한 그룹이 없어요")
                .momogoTypography(.smMedium)
                .foregroundStyle(DesignSystem.Color.gray300)
        }
        .frame(maxWidth: .infinity)
    }
}
