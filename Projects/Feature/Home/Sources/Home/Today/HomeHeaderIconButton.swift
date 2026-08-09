import SwiftUI

import DesignSystem

/// `TodayCardView`의 배너 우상단 plus/settings 버튼. 딤 위에 "+" 버튼 사본을 그려야 하는
/// `momogoMenuOverlay`(DesignSystem)를 위해 `TodayCardView`의 private 헬퍼에서 뷰로 추출했다.
struct HomeHeaderIconButton: View {
    let asset: DesignSystemImages
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(asset: asset)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(DesignSystem.Color.white)
                .padding(12)
                .background(DesignSystem.Color.gray800, in: Circle())
        }
        .accessibilityLabel(accessibilityLabel)
    }
}
