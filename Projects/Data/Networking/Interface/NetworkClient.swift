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

extension NetworkClient: TestDependencyKey {
    public static let testValue = NetworkClient(
        request: unimplemented("\(Self.self).request")
    )
}

public extension DependencyValues {
    var networkClient: NetworkClient {
        get { self[NetworkClient.self] }
        set { self[NetworkClient.self] = newValue }
    }
}
