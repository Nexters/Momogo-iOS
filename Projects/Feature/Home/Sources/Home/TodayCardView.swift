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
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                DSChip(dateText, tone: .gray, size: .small, showsLeadingIcon: false, showsTrailingIcon: false)

                Text("오늘 모모고?")
                    .momogoTypography(.heading26)
                    .foregroundStyle(DesignSystem.Color.gray50)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            RoundedRectangle(cornerRadius: 8)
                .fill(DesignSystem.Color.gray900)
                .stroke(DesignSystem.Color.gray800, lineWidth: 4)
                .overlay {
                    Image(asset: DesignSystemAsset.camera)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(DesignSystem.Color.gray50)
                }
                .frame(width: 96, height: 96)
                .rotationEffect(.degrees(-4))
                .accessibilityHidden(true)
        }
    }
}
