import Foundation

import Dependencies

extension UserDataSource: DependencyKey {
    public static var liveValue: UserDataSource {
        @Dependency(\.networkClient) var networkClient
        @Dependency(\.accessTokenStore) var accessTokenStore
        @Dependency(\.refreshTokenStore) var refreshTokenStore

        return UserDataSource(
            register: { request in
                let response: AuthSessionResponseDTO = try await networkClient
                    .requestDecodable(UserTargetType.register(request))
                persistTokenPair(response, accessTokenStore: accessTokenStore, refreshTokenStore: refreshTokenStore)
                return response
            },
            update: { request in
                try await networkClient.requestDecodable(UserTargetType.update(request))
            },
            delete: {
                _ = try await networkClient.request(UserTargetType.delete)
                clearTokenPair(accessTokenStore: accessTokenStore, refreshTokenStore: refreshTokenStore)
            }
        )
    }

    public static let testValue = UserDataSource(
        register: unimplemented("\(Self.self).register"),
        update: unimplemented("\(Self.self).update"),
        delete: unimplemented("\(Self.self).delete")
    )
}
