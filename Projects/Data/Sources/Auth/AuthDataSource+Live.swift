import Foundation

import Dependencies

extension AuthDataSource: DependencyKey {
    public static var liveValue: AuthDataSource {
        @Dependency(\.networkClient) var networkClient
        @Dependency(\.accessTokenStore) var accessTokenStore
        @Dependency(\.refreshTokenStore) var refreshTokenStore

        return AuthDataSource(
            login: { request in
                let response: AuthSessionResponseDTO = try await networkClient
                    .requestDecodable(AuthTargetType.login(request))
                persistTokenPair(response, accessTokenStore: accessTokenStore, refreshTokenStore: refreshTokenStore)
                return response
            },
            reissue: { request in
                do {
                    let response: ReissueResponseDTO = try await networkClient
                        .requestDecodable(AuthTargetType.reissue(request))
                    persistTokenPair(response, accessTokenStore: accessTokenStore, refreshTokenStore: refreshTokenStore)
                    return response
                } catch {
                    clearTokenPair(accessTokenStore: accessTokenStore, refreshTokenStore: refreshTokenStore)
                    throw error
                }
            },
            logout: { request in
                _ = try await networkClient.request(AuthTargetType.logout(request))
                clearTokenPair(accessTokenStore: accessTokenStore, refreshTokenStore: refreshTokenStore)
            }
        )
    }

    public static let testValue = AuthDataSource(
        login: unimplemented("\(Self.self).login"),
        reissue: unimplemented("\(Self.self).reissue"),
        logout: unimplemented("\(Self.self).logout")
    )
}
