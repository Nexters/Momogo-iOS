import Foundation

import Dependencies

import DomainInterface

/// 백엔드 연동 전까지 사용하는 Mock 구현. AuthRepository의 liveValue는 아직 구현하지 않는다.
extension SignUpUseCase: DependencyKey {
    public static let liveValue = SignUpUseCase(execute: mockSignUp)
}

@Sendable
private func mockSignUp(nickname: String) async throws -> SignUpResponse {
    try? await Task.sleep(for: .seconds(0.4))

    return SignUpResponse(
        userId: Int.random(in: 1...9_999),
        nickname: nickname,
        accessToken: "mock-access-token-\(UUID().uuidString)",
        refreshToken: "mock-refresh-token-\(UUID().uuidString)"
    )
}
