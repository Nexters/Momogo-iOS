import Dependencies
import Foundation
import Testing
@testable import Data

struct AuthDataSourceTests {
    @Test("로그인 성공 시 토큰 스토어를 갱신한다")
    func login_success_updatesTokenStores() async throws {
        let accessTokenStore = AccessTokenStore()
        let refreshTokenStore = RefreshTokenStore()
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"{"userId":1,"nickname":"모모","accessToken":"access","refreshToken":"refresh"}"#.utf8)
            }
            $0.accessTokenStore = accessTokenStore
            $0.refreshTokenStore = refreshTokenStore
        } operation: {
            AuthDataSource.liveValue
        }

        let response = try await dataSource.login(LoginRequestDTO(provider: .guest, providerToken: "token"))

        #expect(response.accessToken == "access")
        #expect(accessTokenStore.current() == "access")
        #expect(refreshTokenStore.current() == "refresh")
    }

    @Test("로그인 실패 시 토큰 스토어를 건드리지 않는다")
    func login_failure_leavesTokenStoresUntouched() async throws {
        let accessTokenStore = AccessTokenStore()
        let refreshTokenStore = RefreshTokenStore()
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in throw NetworkError.unauthorized(problem: nil) }
            $0.accessTokenStore = accessTokenStore
            $0.refreshTokenStore = refreshTokenStore
        } operation: {
            AuthDataSource.liveValue
        }

        await #expect(throws: NetworkError.self) {
            _ = try await dataSource.login(LoginRequestDTO(provider: .guest, providerToken: "token"))
        }
        #expect(accessTokenStore.current() == nil)
        #expect(refreshTokenStore.current() == nil)
    }

    @Test("토큰 재발급 성공 시 토큰 스토어를 갱신한다(rotation)")
    func reissue_success_updatesTokenStores() async throws {
        let accessTokenStore = AccessTokenStore(token: "old-access")
        let refreshTokenStore = RefreshTokenStore(token: "old-refresh")
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"{"accessToken":"new-access","refreshToken":"new-refresh"}"#.utf8)
            }
            $0.accessTokenStore = accessTokenStore
            $0.refreshTokenStore = refreshTokenStore
        } operation: {
            AuthDataSource.liveValue
        }

        let response = try await dataSource.reissue(ReissueRequestDTO(refreshToken: "old-refresh"))

        #expect(response.accessToken == "new-access")
        #expect(accessTokenStore.current() == "new-access")
        #expect(refreshTokenStore.current() == "new-refresh")
    }

    @Test("토큰 재발급 실패 시 토큰 스토어를 모두 초기화한다")
    func reissue_failure_clearsTokenStores() async throws {
        let accessTokenStore = AccessTokenStore(token: "old-access")
        let refreshTokenStore = RefreshTokenStore(token: "expired-refresh")
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in throw NetworkError.unauthorized(problem: nil) }
            $0.accessTokenStore = accessTokenStore
            $0.refreshTokenStore = refreshTokenStore
        } operation: {
            AuthDataSource.liveValue
        }

        await #expect(throws: NetworkError.self) {
            _ = try await dataSource.reissue(ReissueRequestDTO(refreshToken: "expired-refresh"))
        }
        #expect(accessTokenStore.current() == nil)
        #expect(refreshTokenStore.current() == nil)
    }

    @Test("로그아웃 성공 시 토큰 스토어를 모두 초기화한다")
    func logout_success_clearsTokenStores() async throws {
        let accessTokenStore = AccessTokenStore(token: "access")
        let refreshTokenStore = RefreshTokenStore(token: "refresh")
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in Foundation.Data() }
            $0.accessTokenStore = accessTokenStore
            $0.refreshTokenStore = refreshTokenStore
        } operation: {
            AuthDataSource.liveValue
        }

        try await dataSource.logout(LogoutRequestDTO(refreshToken: "refresh"))

        #expect(accessTokenStore.current() == nil)
        #expect(refreshTokenStore.current() == nil)
    }

    @Test("로그아웃 실패 시 로컬 토큰을 유지한다")
    func logout_failure_keepsLocalTokens() async throws {
        let accessTokenStore = AccessTokenStore(token: "access")
        let refreshTokenStore = RefreshTokenStore(token: "refresh")
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in throw NetworkError.serverError(statusCode: 500, problem: nil) }
            $0.accessTokenStore = accessTokenStore
            $0.refreshTokenStore = refreshTokenStore
        } operation: {
            AuthDataSource.liveValue
        }

        await #expect(throws: NetworkError.self) {
            try await dataSource.logout(LogoutRequestDTO(refreshToken: "refresh"))
        }
        #expect(accessTokenStore.current() == "access")
        #expect(refreshTokenStore.current() == "refresh")
    }
}
