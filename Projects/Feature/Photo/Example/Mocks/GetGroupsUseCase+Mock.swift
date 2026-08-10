import Foundation

import DomainInterface

/// 실제 백엔드 연동 전까지 Example 앱에서 플로우를 확인하기 위한 Mock. 프로덕션 liveValue는 그대로 사용한다.
extension GetGroupsUseCase {
    static let happyPath = GetGroupsUseCase {
        try? await Task.sleep(for: .seconds(0.4))

        return GetGroupsResponse(groups: [
            GroupSummary(groupId: 10, groupName: "성민아 밥먹자", totalMemberCount: 9, todayPhotoUploaderCount: 2),
            GroupSummary(groupId: 11, groupName: "우리 가족", totalMemberCount: 2, todayPhotoUploaderCount: 0),
            GroupSummary(groupId: 12, groupName: "예랑이 점심", totalMemberCount: 1, todayPhotoUploaderCount: 1)
        ])
    }
}
