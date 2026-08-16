import Foundation

import Dependencies

public struct AuthDataSource: Sendable {
    public var login: @Sendable (LoginRequestDTO) async throws -> AuthSessionResponseDTO
    public var reissue: @Sendable (ReissueRequestDTO) async throws -> ReissueResponseDTO
    public var logout: @Sendable (LogoutRequestDTO) async throws -> Void

    public init(
        login: @escaping @Sendable (LoginRequestDTO) async throws -> AuthSessionResponseDTO,
        reissue: @escaping @Sendable (ReissueRequestDTO) async throws -> ReissueResponseDTO,
        logout: @escaping @Sendable (LogoutRequestDTO) async throws -> Void
    ) {
        self.login = login
        self.reissue = reissue
        self.logout = logout
    }
}

public extension DependencyValues {
    var authDataSource: AuthDataSource {
        get { self[AuthDataSource.self] }
        set { self[AuthDataSource.self] = newValue }
    }
}
