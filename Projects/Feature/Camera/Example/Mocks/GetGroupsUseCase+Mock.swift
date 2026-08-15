import Foundation

import DomainInterface

/// 실제 백엔드 연동 전까지 Example 앱에서 플로우를 확인하기 위한 Mock. 프로덕션 liveValue는 그대로 사용한다.
/// 그룹 하나(12번)는 오늘 이미 업로드한 상태로 둬서, 업로드 확인 화면에서 선택 불가 카드가 어떻게
/// 보이는지도 함께 확인할 수 있게 한다.
extension GetGroupsUseCase {
    static let happyPath = GetGroupsUseCase {
        try? await Task.sleep(for: .seconds(0.4))

        return GetGroupsResponse(groups: [
            GroupSummary(
                groupId: 10,
                groupName: "성민아 밥먹자",
                totalMemberCount: 9,
                todayPhotoUploaderCount: 2,
                members: ["가가", "나나", "다다", "라라", "마마", "바바", "사사", "아아", "자자"].map {
                    GroupMember(userId: 0, nickname: $0, isMine: false)
                },
                todayPhotoUploaded: false
            ),
            GroupSummary(
                groupId: 11,
                groupName: "우리 가족",
                totalMemberCount: 2,
                todayPhotoUploaderCount: 0,
                members: ["엄마", "아빠"].map { GroupMember(userId: 0, nickname: $0, isMine: false) },
                todayPhotoUploaded: false
            ),
            GroupSummary(
                groupId: 12,
                groupName: "예랑이 점심",
                totalMemberCount: 1,
                todayPhotoUploaderCount: 1,
                members: [GroupMember(userId: 0, nickname: "예랑이", isMine: false)],
                todayPhotoUploaded: true
            )
        ])
    }
}
