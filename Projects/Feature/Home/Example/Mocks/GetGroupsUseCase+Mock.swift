import Foundation

import DomainInterface

/// 실제 백엔드 연동 전까지 Example 앱에서 플로우를 확인하기 위한 Mock. 프로덕션 liveValue는 unimplemented로 유지한다.
extension GetGroupsUseCase {
    /// New 배지 데모용 고정 latestUploadAt. 문자열 대소 비교만 하므로 형식 자체는 중요하지 않지만,
    /// 실제 서버 포맷(Asia/Seoul, 타임존 표기 없음)과 맞춰 눈으로 봤을 때도 자연스럽게 한다.
    static let recentUploadAt = "2026-08-13T09:12:00.000000"

    /// "우리 가족"에는 다른 그룹원이 올린 최신 사진이 있어 New 배지 대상이 되고, "대학 동기"는 활성
    /// 사진이 없어(nil) 애초에 배지 대상이 아니다. 실제로 배지가 뜨는지는 방문 기록 mock(`GroupVisitMockStore`)의
    /// 시드 값에 달려 있다 — HomeExampleRootView의 시나리오 참고.
    static let happyPath = GetGroupsUseCase {
        try? await Task.sleep(for: .seconds(0.4))

        return GetGroupsResponse(groups: [
            GroupSummary(
                groupId: 10,
                groupName: "우리 가족",
                totalMemberCount: 4,
                todayPhotoUploaderCount: 2,
                // true여야 홈 썸네일(`GetMyPhotosUseCase.happyPath`의 사진)이 노출된다.
                todayPhotoUploaded: true,
                latestUploadAt: recentUploadAt
            ),
            GroupSummary(
                groupId: 11,
                groupName: "대학 동기",
                totalMemberCount: 3,
                todayPhotoUploaderCount: 0,
                latestUploadAt: nil
            )
        ])
    }

    static let emptyPath = GetGroupsUseCase {
        try? await Task.sleep(for: .seconds(0.4))
        return GetGroupsResponse(groups: [])
    }

    static let failedPath = GetGroupsUseCase {
        try? await Task.sleep(for: .seconds(0.4))
        throw GetGroupsMockError.failed
    }
}

private enum GetGroupsMockError: Error {
    case failed
}
