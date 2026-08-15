import Foundation

import DomainInterface

extension GetGroupDetailUseCase {
    static let happyPath = GetGroupDetailUseCase { request in
        try? await Task.sleep(for: .seconds(0.4))

        return GetGroupDetailResponse(
            groupId: request.groupId,
            groupName: "우리 가족",
            members: [
                GroupMember(
                    userId: 1,
                    nickname: "나",
                    isMine: true,
                    photo: GroupMemberPhoto(photoId: 3, downloadUrl: "https://picsum.photos/seed/3/400")
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
