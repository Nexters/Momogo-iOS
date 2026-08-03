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
                totalMemberCount: 4,
                todayPhotoUploaderCount: 2
            ),
            GroupSummary(
                groupId: 11,
                groupName: "대학 동기",
                totalMemberCount: 3,
                todayPhotoUploaderCount: 0
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
