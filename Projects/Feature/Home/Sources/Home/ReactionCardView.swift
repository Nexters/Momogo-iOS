import SwiftUI

import DesignSystem
import DomainInterface

/// 오늘 사진을 올린 인원을 보여주는 카드. Figma 디자인의 그릇 모양 일러스트는 제외하고
/// 문구와 아바타만 표시한다.
struct ReactionCardView: View {
    let posters: [GroupMemberPhoto]

    private let diameter: CGFloat = 48
    private let overlap: CGFloat = 27

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            VStack(alignment: .leading, spacing: 4) {
                Text("반응 남기기")
                    .momogoTypography(.heading20)
                    .foregroundStyle(DesignSystem.Color.gray50)

                Text("오늘 \(posters.count)명의 소중한 이가 점심을 올렸어요")
                    .momogoTypography(.xsSemistrong)
                    .foregroundStyle(DesignSystem.Color.gray200)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !posters.isEmpty {
                HStack(spacing: -overlap) {
                    ForEach(posters, id: \.memberId) { poster in
                        GroupAvatarView(photo: poster, diameter: diameter, strokeColor: DesignSystem.Color.gray900)
                    }
                }
                .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.r20)
                .fill(DesignSystem.Color.gray900)
                .stroke(Color.white.opacity(0.04), lineWidth: 2.5)
        )
    }
}
