import Foundation

import Moya

import Dependencies

/// Data가 실제 네트워크 계층에 요구하는 포트.
public struct NetworkClient: Sendable {
    public var request: @Sendable (_ target: any TargetType) async throws -> Data

    public init(
        request: @escaping @Sendable (_ target: any TargetType) async throws -> Data
    ) {
        self.request = request
    }
}

public extension NetworkClient {
    /// 응답 Data를 Decodable 타입으로 디코딩까지 마쳐서 반환한다.
    func requestDecodable<T: Decodable>(
        _ target: any TargetType,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let data = try await request(target)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}

public extension DependencyValues {
    var networkClient: NetworkClient {
        get { self[NetworkClient.self] }
        set { self[NetworkClient.self] = newValue }
    }
}
