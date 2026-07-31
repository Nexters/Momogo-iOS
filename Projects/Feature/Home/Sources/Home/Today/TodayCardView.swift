import SwiftUI

import DesignSystem

struct TodayCardView: View {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter
    }()

    private var dateText: String {
        Self.dateFormatter.string(from: Date())
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                DSChip(dateText, tone: .gray, size: .small, showsLeadingIcon: false, showsTrailingIcon: false)

                Text("오늘 모모고?")
                    .momogoTypography(.heading26)
                    .foregroundStyle(DesignSystem.Color.gray50)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 회전은 배경 사각형에만 적용된다. 카메라 아이콘은 회전하지 않고 그대로 중앙에 위치한다.
            ZStack {
                // Figma 스펙은 8px이지만 DesignSystem에 정의된 값이 아니라 가장 가까운 r10을 사용한다.
                RoundedRectangle(cornerRadius: DesignSystem.Radius.r10)
                    .fill(DesignSystem.Color.gray900)
                    .stroke(DesignSystem.Color.gray800, lineWidth: 4.5)
                    .rotationEffect(.degrees(-4))

                Image(asset: DesignSystemAsset.camera)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(DesignSystem.Color.gray400)
            }
            .frame(width: 124, height: 124)
            .accessibilityHidden(true)
        }
    }
}
