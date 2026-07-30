import SwiftUI

import DesignSystem
import DomainInterface

/// 아바타 스택의 원 하나. `photo`가 있으면 실제 이미지를, 없으면 회색 placeholder를 보여준다.
struct GroupAvatarView: View {
    let photo: GroupMemberPhoto?
    let diameter: CGFloat

    var body: some View {
        Group {
            if let photo, let url = URL(string: photo.url) {
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
        .overlay {
            Circle().stroke(DesignSystem.Color.gray800, lineWidth: 2)
        }
    }
}
