import SwiftUI

import DesignSystem

/// 선택 그룹에 그날 올라온 사진들을 나타내는 인디케이터. 선택된 dot만 커지고, 아직 사진을 올리지
/// 않은 그룹원의 dot은 흐리게 표시된다.
struct ReactionIndicatorView: View {
    struct Constants {
        let dotSize: CGFloat = 5
        let selectedDotSize: CGFloat = 10
        let dotSpacing: CGFloat = 8
        let horizontalPadding: CGFloat = 12
        let verticalPadding: CGFloat = 8
        let outerHorizontalPadding: CGFloat = 16
        let notUploadedDotOpacity: CGFloat = 0.08
    }

    private let constants = Constants()

    let items: [ReactionPhotoItem]
    let selectedItemId: Int?

    var body: some View {
        HStack(spacing: constants.dotSpacing) {
            ForEach(items) { item in
                let isSelected = item.id == selectedItemId
                let size = isSelected ? constants.selectedDotSize : constants.dotSize

                Circle()
                    .fill(color(for: item, isSelected: isSelected))
                    .frame(width: size, height: size)
            }
        }
        .padding(.horizontal, constants.horizontalPadding)
        .padding(.vertical, constants.verticalPadding)
        .background(
            DesignSystem.Color.gray900,
            in: RoundedRectangle(cornerRadius: DesignSystem.Radius.r12)
        )
        .frame(maxWidth: .infinity)
        .padding(.horizontal, constants.outerHorizontalPadding)
    }

    /// 셀렉된 dot이 내 사진이면 primary500, 남의 사진이면 흰색. 선택되지 않은 dot은 업로드 여부로
    /// gray100(올림) / 흰색 8%(안 올림)를 가른다.
    private func color(for item: ReactionPhotoItem, isSelected: Bool) -> Color {
        if isSelected {
            item.member.isMine ? DesignSystem.Color.primary500 : DesignSystem.Color.white
        } else if item.hasPhoto {
            DesignSystem.Color.gray100
        } else {
            DesignSystem.Color.white.opacity(constants.notUploadedDotOpacity)
        }
    }
}
