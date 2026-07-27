import Foundation

import Dependencies

import DomainInterface

extension SignUpUseCase: DependencyKey {
    public static let liveValue = SignUpUseCase(execute: signUp(nickname:))
}

@Sendable
private func signUp(nickname: String) async throws -> SignUpResponse {
    @Dependency(\.authRepository) var authRepository

    let request = SignUpRequest(provider: .guest, providerToken: "", nickname: nickname)
    return try await authRepository.signUp(request)
}
