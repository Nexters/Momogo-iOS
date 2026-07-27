import Foundation

import DomainInterface

/// 실제 백엔드 연동 전까지 Example 앱에서 플로우를 확인하기 위한 Mock. 프로덕션 liveValue는 unimplemented로 유지한다.
extension SignUpUseCase {
    static let mock = SignUpUseCase { nickname in
        try? await Task.sleep(for: .seconds(0.4))

        return SignUpResponse(
            userId: Int.random(in: 1...9_999),
            nickname: nickname,
            accessToken: "mock-access-token-\(UUID().uuidString)",
            refreshToken: "mock-refresh-token-\(UUID().uuidString)"
        )
    }
}
