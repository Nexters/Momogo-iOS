import Foundation

import Dependencies

import DomainInterface

extension AuthRepository: DependencyKey {
    public static var liveValue: AuthRepository {
        @Dependency(\.userDataSource) var userDataSource
        @Dependency(\.authDataSource) var authDataSource
        @Dependency(\.accessTokenStore) var accessTokenStore
        @Dependency(\.refreshTokenStore) var refreshTokenStore
        @Dependency(\.guestTokenStore) var guestTokenStore

        return AuthRepository(
            signUp: { request in
                let dto = RegisterRequestDTO(
                    provider: request.provider.dataProvider,
                    providerToken: request.providerToken,
                    nickname: request.nickname
                )
                let response = try await userDataSource.register(dto)
                return SignUpResponse(
                    userId: response.userId,
                    nickname: response.nickname,
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
            },
            refreshSession: {
                guard let refreshToken = refreshTokenStore.current() else { return false }
                do {
                    _ = try await authDataSource.reissue(ReissueRequestDTO(refreshToken: refreshToken))
                    return true
                } catch {
                    return false
                }
            },
            login: {
                let providerToken = guestTokenStore.fetchOrCreate()
                do {
                    _ = try await authDataSource.login(LoginRequestDTO(provider: .guest, providerToken: providerToken))
                    return true
                } catch {
                    return false
                }
            },
            logout: {
                guard let refreshToken = refreshTokenStore.current() else { return true }
                do {
                    try await authDataSource.logout(LogoutRequestDTO(refreshToken: refreshToken))
                    return true
                } catch {
                    return false
                }
            },
            clearLocalAuthState: {
                accessTokenStore.update(nil)
                refreshTokenStore.update(nil)
                guestTokenStore.clear()
            }
        )
    }
}

private extension DomainInterface.AuthProvider {
    /// Domain의 AuthProvider와 Data의 AuthProvider는 이름이 같아 반드시 모듈로 한정해서 구분한다.
    var dataProvider: AuthProvider {
        switch self {
        case .guest:
            .guest
        }
    }
}
