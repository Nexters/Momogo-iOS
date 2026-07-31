import SwiftUI

import DesignSystem
import DomainInterface

/// 아바타 스택의 원 하나. `photo`가 있으면 실제 이미지를, 없으면 회색 placeholder를 보여준다.
/// `strokeColor`는 겹침 컷아웃 효과를 위한 테두리 색으로, 이 뷰가 올라가는 배경색과 맞춰야 한다.
struct GroupAvatarView: View {
    let photo: GroupMemberPhoto?
    let diameter: CGFloat
    let strokeColor: Color

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
            Circle().stroke(strokeColor, lineWidth: 2)
        }
    }
}
