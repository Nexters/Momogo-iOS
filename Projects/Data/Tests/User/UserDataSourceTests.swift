import Foundation
import Testing
import Dependencies
@testable import Data

struct UserDataSourceTests {
    @Test("회원가입 성공 시 응답을 반환하고 토큰 스토어를 갱신한다")
    func register_success_updatesTokenStores() async throws {
        let accessTokenStore = AccessTokenStore()
        let refreshTokenStore = RefreshTokenStore()
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"{"userId":1,"nickname":"모모","accessToken":"access","refreshToken":"refresh"}"#.utf8)
            }
            $0.accessTokenStore = accessTokenStore
            $0.refreshTokenStore = refreshTokenStore
        } operation: {
            UserDataSource.liveValue
        }

        let response = try await dataSource.register(
            RegisterRequestDTO(provider: .kakao, providerToken: "token", nickname: "모모")
        )

        #expect(response.accessToken == "access")
        #expect(accessTokenStore.current() == "access")
        #expect(refreshTokenStore.current() == "refresh")
    }

    @Test("회원가입 실패 시 토큰 스토어를 건드리지 않는다")
    func register_failure_leavesTokenStoresUntouched() async throws {
        let accessTokenStore = AccessTokenStore()
        let refreshTokenStore = RefreshTokenStore()
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in throw NetworkError.serverError(statusCode: 400, problem: nil) }
            $0.accessTokenStore = accessTokenStore
            $0.refreshTokenStore = refreshTokenStore
        } operation: {
            UserDataSource.liveValue
        }

        await #expect(throws: NetworkError.self) {
            _ = try await dataSource.register(
                RegisterRequestDTO(provider: .guest, providerToken: "token", nickname: "모모")
            )
        }
        #expect(accessTokenStore.current() == nil)
        #expect(refreshTokenStore.current() == nil)
    }

    @Test("유저 수정 성공 시 응답을 반환한다")
    func update_success_returnsResponse() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"{"userId":1,"nickname":"모모2"}"#.utf8)
            }
        } operation: {
            UserDataSource.liveValue
        }

        let response = try await dataSource.update(UpdateUserRequestDTO(nickname: "모모2"))

        #expect(response.nickname == "모모2")
    }

    @Test("탈퇴 성공 시 토큰 스토어를 모두 초기화한다")
    func delete_success_clearsTokenStores() async throws {
        let accessTokenStore = AccessTokenStore(token: "access")
        let refreshTokenStore = RefreshTokenStore(token: "refresh")
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in Foundation.Data() }
            $0.accessTokenStore = accessTokenStore
            $0.refreshTokenStore = refreshTokenStore
        } operation: {
            UserDataSource.liveValue
        }

        try await dataSource.delete()

        #expect(accessTokenStore.current() == nil)
        #expect(refreshTokenStore.current() == nil)
    }

    @Test("응답 디코딩 실패 시 decodingFailed를 던진다")
    func register_invalidJSON_throwsDecodingFailed() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in Foundation.Data(#"{"unexpected":"field"}"#.utf8) }
        } operation: {
            UserDataSource.liveValue
        }

        await #expect(throws: NetworkError.self) {
            _ = try await dataSource.register(
                RegisterRequestDTO(provider: .guest, providerToken: "token", nickname: "모모")
            )
        }
    }
}
