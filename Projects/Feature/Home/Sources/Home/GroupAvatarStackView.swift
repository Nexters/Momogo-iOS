import SwiftUI

import DesignSystem
import DomainInterface

/// 그룹 카드의 멤버 아바타를 겹쳐서 보여주는 뷰. `totalMemberCount`만큼 슬롯을 만들고,
/// 앞쪽 슬롯부터 `photos`의 실제 이미지를 채우며 나머지는 회색 placeholder로 표시한다.
struct GroupAvatarStackView: View {
    let photos: [GroupMemberPhoto]
    let totalMemberCount: Int

    private let diameter: CGFloat = 32
    private let overlap: CGFloat = 16

    var body: some View {
        HStack(spacing: -overlap) {
            ForEach(0..<totalMemberCount, id: \.self) { index in
                avatar(for: index)
                    .zIndex(Double(totalMemberCount - index))
            }
        }
    }

    @ViewBuilder
    private func avatar(for index: Int) -> some View {
        Group {
            if index < photos.count, let url = URL(string: photos[index].url) {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFill()
                    } else {
                        DesignSystem.Color.gray700
                    }
                }
            } else {
                DesignSystem.Color.gray700
            }
        }
        .frame(width: diameter, height: diameter)
        .clipShape(Circle())
        .overlay(Circle().stroke(HomeColor.groupCardBackground, lineWidth: 2))
    }
}
