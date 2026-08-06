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

private let provider = MoyaProvider<MultiTarget>(plugins: providerPlugins)

private var providerPlugins: [PluginType] {
    var plugins: [PluginType] = [AuthorizationPlugin(tokenStore: AccessTokenStore.liveValue)]
    #if DEBUG
        plugins.append(NetworkLoggerPlugin())
    #endif
    return plugins
}

@Sendable
private func performRequest(_ target: any TargetType) async throws -> Data {
    do {
        let response: Response = try await withCheckedThrowingContinuation { continuation in
            provider.request(MultiTarget(target)) { result in
                continuation.resume(with: result)
            }
        }
        return response.data
    } catch let error as MoyaError {
        throw mapToNetworkError(error)
    } catch {
        throw NetworkError.underlying(error)
    }
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
