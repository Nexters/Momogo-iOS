import Foundation

import DomainInterface

extension GroupMember {
    /// Figma의 상태들을 스와이프로 훑을 수 있게 구성한 목 그룹원.
    /// userId 1 = 내 점심(리액션 있음), 2 = 친구 점심(리액션 있음), 3 = 친구 점심 엠티뷰,
    /// 4 = 친구 점심 미업로드. 리액션 개수 규칙은 `ReactionViewModel`의 목 데이터 상수를 참고한다.
    static let reactionMocks: [GroupMember] = [
        GroupMember(
            userId: 1,
            nickname: "나",
            isMine: true,
            photo: GroupMemberPhoto(photoId: 501, downloadUrl: "https://picsum.photos/seed/3/800")
        ),
        GroupMember(
            userId: 2,
            nickname: "길동",
            isMine: false,
            photo: GroupMemberPhoto(photoId: 1, downloadUrl: "https://picsum.photos/seed/1/800")
        ),
        GroupMember(
            userId: 3,
            nickname: "나미",
            isMine: false,
            photo: GroupMemberPhoto(photoId: 2, downloadUrl: "https://picsum.photos/seed/2/800")
        ),
        GroupMember(userId: 4, nickname: "철수", isMine: false, photo: nil)
    ]
}
