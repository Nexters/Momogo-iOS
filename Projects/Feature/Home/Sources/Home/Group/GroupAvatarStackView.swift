import SwiftUI

import DesignSystem
import DomainInterface

/// 그룹 카드의 멤버 아바타를 겹쳐서 보여주는 뷰. `totalMemberCount`만큼 슬롯을 만들고,
/// 앞쪽 슬롯부터 `photos`의 실제 이미지를 채우며 나머지는 회색 placeholder로 표시한다.
/// 참여 인원은 카드의 "N / M" 텍스트로 이미 전달되므로 스택 자체는 장식용으로 취급한다.
struct GroupAvatarStackView: View {
    let photos: [GroupMemberPhoto]
    let totalMemberCount: Int

    private let diameter: CGFloat = 32
    private let overlap: CGFloat = 16

    var body: some View {
        HStack(spacing: -overlap) {
            ForEach(0..<totalMemberCount, id: \.self) { index in
                GroupAvatarView(
                    photo: index < photos.count ? photos[index] : nil,
                    diameter: diameter,
                    strokeColor: DesignSystem.Color.gray800
                )
                .zIndex(Double(totalMemberCount - index))
            }
        }
        .accessibilityHidden(true)
    }
}
