import SwiftUI

import DesignSystem

/// 오늘 사진을 올린 인원 수를 보여주는 카드. 그룹 목록 API가 인원 사진이 아닌 집계 수치만 제공해
/// Figma 디자인의 아바타 스택은 생략하고 문구만 표시한다.
struct ReactionCardView: View {
    let posterCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("반응 남기기")
                .momogoTypography(.heading20)
                .foregroundStyle(DesignSystem.Color.gray50)

            Text("오늘 \(posterCount)명의 소중한 이가 점심을 올렸어요")
                .momogoTypography(.xsSemistrong)
                .foregroundStyle(DesignSystem.Color.gray200)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.r20)
                .fill(DesignSystem.Color.gray900)
                .stroke(Color.white.opacity(0.04), lineWidth: 2.5)
        )
    }
}
