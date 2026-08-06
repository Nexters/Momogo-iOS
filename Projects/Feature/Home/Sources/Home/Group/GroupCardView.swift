import SwiftUI

import DesignSystem
import DomainInterface

struct GroupCardView: View {
    let group: GroupSummary

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text(group.groupName)
                    .momogoTypography(.lgSemistrong)
                    .foregroundStyle(DesignSystem.Color.white)

                memberDots
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(asset: DesignSystemAsset.chevronRightFill)
                .resizable()
                .scaledToFit()
                .frame(width: 9, height: 16)
                .foregroundStyle(DesignSystem.Color.gray400)
        }
        .padding(.leading, 24)
        .padding(.trailing, 12)
        .padding(.vertical, 20)
        .background(DesignSystem.Color.gray800)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r16))
        .momogoShadow()
    }

    /// 멤버별 업로드 여부 데이터가 없어, 그룹 인원 수만큼 점을 그리고 앞쪽 `todayPhotoUploaderCount`개를
    /// 업로드 완료 상태 색으로 채우는 방식으로 근사한다.
    private var memberDots: some View {
        HStack(spacing: 3) {
            ForEach(0..<group.totalMemberCount, id: \.self) { index in
                Image(asset: DesignSystemAsset.memberDot)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 11, height: 15)
                    .foregroundStyle(
                        index < group.todayPhotoUploaderCount
                            ? DesignSystem.Color.gray100
                            : Color.white.opacity(0.08)
                    )
            }
        }
        .accessibilityHidden(true)
    }
}
