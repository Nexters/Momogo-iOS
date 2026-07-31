import Foundation

import DomainInterface

/// 실제 백엔드 연동 전까지 Example 앱에서 플로우를 확인하기 위한 Mock. 프로덕션 liveValue는 unimplemented로 유지한다.
extension GetGroupsUseCase {
    static let happyPath = GetGroupsUseCase {
        try? await Task.sleep(for: .seconds(0.4))

        return GetGroupsResponse(groups: [
            GroupSummary(
                groupId: 10,
                groupName: "우리 가족",
                invitationCode: "A1B2C3D4",
                participateMemberCount: 2,
                totalMemberCount: 4,
                joinedDate: "2026-07-25 14:30:00.123456+00",
                photos: [
                    GroupMemberPhoto(photoId: 501, memberId: 22, url: "https://picsum.photos/seed/momogo1/200"),
                    GroupMemberPhoto(photoId: 502, memberId: 23, url: "https://picsum.photos/seed/momogo2/200")
                ]
            ),
            GroupSummary(
                groupId: 11,
                groupName: "대학 동기",
                invitationCode: "E5F6G7H8",
                participateMemberCount: 0,
                totalMemberCount: 3,
                joinedDate: "2026-07-20 09:00:00.000000+00",
                photos: []
            )
        ])
    }

    static let failedPath = GetGroupsUseCase {
        try? await Task.sleep(for: .seconds(0.4))
        throw GetGroupsMockError.failed
    }
}

private enum GetGroupsMockError: Error {
    case failed
}
