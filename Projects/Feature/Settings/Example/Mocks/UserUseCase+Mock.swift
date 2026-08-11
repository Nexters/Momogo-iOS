import Foundation

import DomainInterface

/// 실제 백엔드 연동 전까지 Example 앱에서 플로우를 확인하기 위한 Mock. 프로덕션 liveValue는 unimplemented로 유지한다.
extension UpdateNicknameUseCase {
    static let happyPath = UpdateNicknameUseCase { _ in
        try? await Task.sleep(for: .seconds(0.4))
    }

    static let failedPath = UpdateNicknameUseCase { _ in
        try? await Task.sleep(for: .seconds(0.4))
        throw UserMockError.failed
    }
}

extension DeleteAccountUseCase {
    static let happyPath = DeleteAccountUseCase {
        try? await Task.sleep(for: .seconds(0.4))
    }

    static let failedPath = DeleteAccountUseCase {
        try? await Task.sleep(for: .seconds(0.4))
        throw UserMockError.failed
    }
}

private enum UserMockError: Error {
    case failed
}
