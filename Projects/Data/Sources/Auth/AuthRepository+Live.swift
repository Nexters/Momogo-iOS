import Foundation

import Dependencies

import DomainInterface

extension AuthRepository: DependencyKey {
    public static var liveValue: AuthRepository {
        @Dependency(\.authDataSource) var authDataSource
        @Dependency(\.refreshTokenStore) var refreshTokenStore

        return AuthRepository(
            signUp: unimplemented("\(Self.self).signUp"),
            refreshSession: {
                guard let refreshToken = refreshTokenStore.current() else { return false }
                do {
                    _ = try await authDataSource.reissue(ReissueRequestDTO(refreshToken: refreshToken))
                    return true
                } catch {
                    return false
                }
            }
        )
    }
}
