import Foundation

import DomainInterface

extension GetGroupDetailUseCase {
    static let happyPath = GetGroupDetailUseCase { request in
        try? await Task.sleep(for: .seconds(0.4))

        return GetGroupDetailResponse(
            groupId: request.groupId,
            groupName: "우리 가족",
            invitationCode: "ABC123",
            members: [
                GroupMember(
                    userId: 1,
                    nickname: "나",
                    isMine: true,
                    // `GetMyPhotosUseCase.happyPath`의 photoId(501)와 맞물려야 홈 썸네일이 노출된다.
                    photo: GroupMemberPhoto(photoId: 501, downloadUrl: "https://picsum.photos/seed/3/400")
                ),
                GroupMember(
                    userId: 2,
                    nickname: "길동",
                    isMine: false,
                    photo: GroupMemberPhoto(photoId: 1, downloadUrl: "https://picsum.photos/seed/1/400")
                ),
                GroupMember(
                    userId: 3,
                    nickname: "나미",
                    isMine: false,
                    photo: GroupMemberPhoto(photoId: 2, downloadUrl: "https://picsum.photos/seed/2/400")
                ),
                GroupMember(userId: 4, nickname: "철수", isMine: false, photo: nil)
            ]
        )
    }
}
