import Foundation

import DomainInterface

/// 실제 백엔드 연동 전까지 Example 앱에서 플로우를 확인하기 위한 Mock. 프로덕션 liveValue는 unimplemented로 유지한다.
extension CreateGroupUseCase {
    static let happyPath = CreateGroupUseCase { groupName in
        try? await Task.sleep(for: .seconds(0.4))

        return CreateGroupResponse(
            groupId: Int.random(in: 1 ... 9999),
            groupName: groupName,
            invitationCode: String(UUID().uuidString.prefix(8)).uppercased()
        )
    }

    static let failedPath = CreateGroupUseCase { _ in
        try? await Task.sleep(for: .seconds(0.4))
        throw CreateGroupMockError.failed
    }

    /// 풀스크린 로딩 오버레이(`momogoLoadingOverlay`)를 Example에서 눈으로 확인하기 위한 지연 시나리오.
    static let longDelay = CreateGroupUseCase { groupName in
        try? await Task.sleep(for: .seconds(5))

        return CreateGroupResponse(
            groupId: Int.random(in: 1 ... 9999),
            groupName: groupName,
            invitationCode: String(UUID().uuidString.prefix(8)).uppercased()
        )
    }
}

private enum CreateGroupMockError: Error {
    case failed
}
