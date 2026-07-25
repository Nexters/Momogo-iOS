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

private let provider = MoyaProvider<MultiTarget>()

@Sendable
private func performRequest(_ target: any TargetType) async throws -> Data {
    let response: Response = try await withCheckedThrowingContinuation { continuation in
        provider.request(MultiTarget(target)) { result in
            switch result {
            case let .success(response):
                continuation.resume(returning: response)
            case let .failure(error):
                continuation.resume(throwing: NetworkError.requestFailed(error))
            }
        }
    }
    return response.data
}
