import Foundation

import DomainInterface

/// 실제 백엔드 연동 전까지 Example 앱에서 플로우를 확인하기 위한 Mock. 프로덕션 liveValue는 unimplemented로 유지한다.
extension JoinGroupByCodeUseCase {
    static let happyPath = JoinGroupByCodeUseCase { code in
        try? await Task.sleep(for: .seconds(0.4))
        return JoinGroupByCodeResponse(groupId: 10, code: code)
    }

    static let failedPath = JoinGroupByCodeUseCase { _ in
        try? await Task.sleep(for: .seconds(0.4))
        throw JoinGroupByCodeMockError.failed
    }
}

private enum JoinGroupByCodeMockError: Error {
    case failed
}
