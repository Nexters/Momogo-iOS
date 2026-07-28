import Foundation

import Moya

/// Data 모듈의 모든 API 정의가 채택하는 공통 TargetType.
/// 엔드포인트별로는 `path`/`method`/`task`, 필요 시 `requiresAuthorization`만 정의하면 된다.
public protocol NetworkTargetType: TargetType {
    var requiresAuthorization: Bool { get }
}

public extension NetworkTargetType {
    var baseURL: URL {
        NetworkConfiguration.baseURL
    }

    var headers: [String: String]? {
        nil
    }

    var validationType: ValidationType {
        .successCodes
    }

    var sampleData: Data {
        Data()
    }

    var requiresAuthorization: Bool {
        true
    }
}
