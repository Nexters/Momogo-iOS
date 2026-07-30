import Foundation

protocol TokenPairResponse {
    var accessToken: String { get }
    var refreshToken: String { get }
}

extension AuthSessionResponseDTO: TokenPairResponse {}
extension ReissueResponseDTO: TokenPairResponse {}

func persistTokenPair(
    _ response: some TokenPairResponse,
    accessTokenStore: AccessTokenStore,
    refreshTokenStore: RefreshTokenStore
) {
    accessTokenStore.update(response.accessToken)
    refreshTokenStore.update(response.refreshToken)
}

func clearTokenPair(accessTokenStore: AccessTokenStore, refreshTokenStore: RefreshTokenStore) {
    accessTokenStore.update(nil)
    refreshTokenStore.update(nil)
}
