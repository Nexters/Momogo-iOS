import Foundation

import Dependencies

import DomainInterface

/// 백엔드 연동 전까지 사용하는 회원가입 Mock 구현체.
extension AuthRepository: DependencyKey {
    public static let liveValue = AuthRepository(signUp: mockSignUp)
}

@Sendable
private func mockSignUp(_ request: SignUpRequest) async throws -> SignUpResponse {
    try? await Task.sleep(for: .seconds(0.4))

    return SignUpResponse(
        userId: Int.random(in: 1...9_999),
        nickname: request.nickname,
        accessToken: "mock-access-token-\(UUID().uuidString)",
        refreshToken: "mock-refresh-token-\(UUID().uuidString)"
    )
}
