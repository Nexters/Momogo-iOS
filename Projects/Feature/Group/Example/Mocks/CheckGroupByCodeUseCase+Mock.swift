import Foundation

import DomainInterface

/// 실제 백엔드 연동 전까지 Example 앱에서 플로우를 확인하기 위한 Mock. 프로덕션 liveValue는 unimplemented로 유지한다.
extension CheckGroupByCodeUseCase {
    static let happyPath = CheckGroupByCodeUseCase { _ in
        try? await Task.sleep(for: .seconds(0.4))

        return CheckGroupByCodeResponse(
            groupId: 10,
            groupName: "우리 가족",
            totalMemberCount: 4,
            participated: false
        )
    }

    static let failedPath = CheckGroupByCodeUseCase { _ in
        try? await Task.sleep(for: .seconds(0.4))
        throw CheckGroupByCodeMockError.failed
    }

    static let invalidCodePath = CheckGroupByCodeUseCase { _ in
        try? await Task.sleep(for: .seconds(0.4))
        throw GroupJoinError.invalidInvitationCode
    }

    /// 풀스크린 로딩 오버레이(`momogoLoadingOverlay`)를 Example에서 눈으로 확인하기 위한 지연 시나리오.
    static let longDelay = CheckGroupByCodeUseCase { _ in
        try? await Task.sleep(for: .seconds(5))

        return CheckGroupByCodeResponse(
            groupId: 10,
            groupName: "우리 가족",
            totalMemberCount: 4,
            participated: false
        )
    }
}

private enum CheckGroupByCodeMockError: Error {
    case failed
}
