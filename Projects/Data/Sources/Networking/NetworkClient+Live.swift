import Foundation

import Moya

import Dependencies

extension NetworkClient: DependencyKey {
    public static let liveValue = NetworkClient(request: performRequest)

    public static let testValue = NetworkClient(
        request: unimplemented("\(Self.self).request")
    )

    /// SwiftUI 프리뷰에서 실제 네트워크를 타지 않도록 빈 응답을 반환한다.
    public static let previewValue = NetworkClient(
        request: { _ in Data() }
    )
}

/// `NetworkClient.liveValue`는 프로세스에서 딱 한 번만 만들어지는 실제 네트워크 계층이라,
/// provider(Moya 세션)와 tokenRefresher(동시 401을 묶는 상태)는 요청마다 다시 만들면 안 되는
/// 진짜 싱글턴이라서 전역에 둔다. accessToken/refreshToken 스토어는 그럴 필요가 없어서
/// 필요한 곳(providerPlugins, reissueAccessToken)에서 `@Dependency`로 그때그때 가져온다.
private let provider = MoyaProvider<MultiTarget>(plugins: providerPlugins)

/// 401 발생 시 accessToken을 재발급받는 흐름. 실제 재발급 호출/토큰 영속화는
/// `reissueAccessToken`에 위임하고, 여기서는 동시 401에 대한 single-flight만 담당한다.
private let tokenRefresher = TokenRefresher(refresh: reissueAccessToken)

private var providerPlugins: [PluginType] {
    @Dependency(\.accessTokenStore) var accessTokenStore

    var plugins: [PluginType] = [AuthorizationPlugin(tokenStore: accessTokenStore)]
    #if DEBUG
        plugins.append(NetworkLoggerPlugin())
    #endif
    return plugins
}

@Sendable
private func performRequest(_ target: any TargetType) async throws -> Data {
    try await performRequest(target, hasRetriedAfterRefresh: false, networkRetryCount: 0)
}

private func performRequest(
    _ target: any TargetType,
    hasRetriedAfterRefresh: Bool,
    networkRetryCount: Int
) async throws -> Data {
    do {
        let response = try await sendMoyaRequest(target, using: provider)
        return response.data
    } catch let error as MoyaError {
        if !hasRetriedAfterRefresh, isUnauthorized(error, target: target) {
            do {
                try await tokenRefresher.refreshIfNeeded()
            } catch let refreshError as MoyaError {
                throw mapToNetworkError(refreshError)
            }
            return try await performRequest(target, hasRetriedAfterRefresh: true, networkRetryCount: networkRetryCount)
        }

        if networkRetryCount < NetworkRetryPolicy.maxRetryCount, NetworkRetryPolicy.isRetryable(error) {
            // `Moya.Task`와 이름이 겹치므로 Swift Concurrency의 Task임을 명시한다.
            try await _Concurrency.Task.sleep(for: NetworkRetryPolicy.delay(forAttempt: networkRetryCount))
            return try await performRequest(
                target,
                hasRetriedAfterRefresh: hasRetriedAfterRefresh,
                networkRetryCount: networkRetryCount + 1
            )
        }

        throw mapToNetworkError(error)
    } catch {
        throw NetworkError.underlying(error)
    }
}

/// Moya provider의 콜백 기반 API를 async/await로 감싼다. `TokenRefresher`의 reissue 호출도
/// 동일한 provider로 이 함수를 공유해서 보낸다.
func sendMoyaRequest(_ target: any TargetType, using provider: MoyaProvider<MultiTarget>) async throws -> Response {
    try await withCheckedThrowingContinuation { continuation in
        provider.request(MultiTarget(target)) { result in
            continuation.resume(with: result)
        }
    }
}

/// accessToken을 재발급받고 성공/실패에 따라 토큰 스토어를 갱신/초기화한다.
/// 실패 시(리프레시 토큰 없음, 재발급 API 실패 등) `AuthDataSource.reissue`와 동일하게 토큰을 모두 clear한다.
@Sendable
private func reissueAccessToken() async throws {
    @Dependency(\.accessTokenStore) var accessTokenStore
    @Dependency(\.refreshTokenStore) var refreshTokenStore

    guard let refreshToken = refreshTokenStore.current() else {
        clearTokenPair(accessTokenStore: accessTokenStore, refreshTokenStore: refreshTokenStore)
        throw NetworkError.unauthorized(problem: nil)
    }

    do {
        let response = try await sendMoyaRequest(
            AuthTargetType.reissue(ReissueRequestDTO(refreshToken: refreshToken)),
            using: provider
        )
        let decoded = try decodeReissueResponse(from: response)
        persistTokenPair(decoded, accessTokenStore: accessTokenStore, refreshTokenStore: refreshTokenStore)
    } catch {
        clearTokenPair(accessTokenStore: accessTokenStore, refreshTokenStore: refreshTokenStore)
        throw error
    }
}

private func decodeReissueResponse(from response: Response) throws -> ReissueResponseDTO {
    do {
        return try JSONDecoder().decode(ReissueResponseDTO.self, from: response.data)
    } catch {
        throw NetworkError.decodingFailed(error)
    }
}

/// 인증이 필요한 요청이 401을 받았는지 판단한다. `requiresAuthorization`이 false인
/// 로그인/재발급 요청은 재발급 대상에서 제외해 무한 루프를 막는다.
func isUnauthorized(_ error: MoyaError, target: any TargetType) -> Bool {
    guard error.response?.statusCode == 401 else { return false }
    let underlyingTarget = (target as? MultiTarget)?.target ?? target
    guard let networkTarget = underlyingTarget as? any NetworkTargetType else { return false }
    return networkTarget.requiresAuthorization
}

func mapToNetworkError(_ error: MoyaError) -> NetworkError {
    guard let statusCode = error.response?.statusCode else {
        return .underlying(error)
    }
    let problem = error.response.flatMap { try? JSONDecoder().decode(ProblemDetail.self, from: $0.data) }
    switch statusCode {
    case 401:
        return .unauthorized(problem: problem)
    default:
        return .serverError(statusCode: statusCode, problem: problem)
    }
}
