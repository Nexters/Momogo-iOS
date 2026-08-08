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

            // Figma 스펙: 아이콘 자체는 9.2x16이지만 24x24 탭 슬롯 안에 중앙 정렬되어 있어, 카드
            // 오른쪽 여백(pr-12 + 슬롯 인셋)만큼 자연스러운 여유가 생긴다. 색상은 원본 SVG의 실제
            // fill(#464443=gray700)을 따른다 — gray400은 스펙보다 밝다.
            Image(asset: DesignSystemAsset.chevronRightFill)
                .resizable()
                .scaledToFit()
                .frame(width: 9, height: 16)
                .foregroundStyle(DesignSystem.Color.gray700)
                .frame(width: 24, height: 24)
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
