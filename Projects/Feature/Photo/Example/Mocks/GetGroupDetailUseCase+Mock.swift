import Foundation

import DomainInterface

/// 실제 백엔드 연동 전까지 Example 앱에서 플로우를 확인하기 위한 Mock.
/// `GetGroupsUseCase+Mock`의 그룹 ID(10/11/12)에 맞춰 멤버 이름을 돌려준다.
extension GetGroupDetailUseCase {
    static let happyPath = GetGroupDetailUseCase { request in
        try? await Task.sleep(for: .seconds(0.2))

        let membersByGroupID: [Int: [String]] = [
            10: ["가가", "나나", "다다", "라라", "마마", "바바", "사사", "아아", "자자"],
            11: ["엄마", "아빠"],
            12: ["예랑이"]
        ]
        let nicknames = membersByGroupID[request.groupId] ?? []

        return GetGroupDetailResponse(
            groupId: request.groupId,
            groupName: "",
            members: nicknames.enumerated().map { index, nickname in
                GroupMember(userId: index, nickname: nickname, isMine: index == 0)
            }
        )
    }
}
