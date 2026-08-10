import Foundation

import Moya

enum VersionTargetType: NetworkTargetType {
    case check

    /// `/init/versions`는 `/api/v1` 경로가 붙지 않는 루트 엔드포인트라 baseURL을 override한다.
    var baseURL: URL {
        NetworkConfiguration.rootURL
    }

    var path: String {
        "/init/versions"
    }

    var method: Moya.Method {
        .get
    }

    var task: Moya.Task {
        .requestParameters(
            parameters: [
                "platform": "IOS",
                "appVersion": NetworkConfiguration.appVersion
            ],
            encoding: URLEncoding.queryString
        )
    }

    /// 스플래시 시점엔 토큰이 없을 수 있어 인증 헤더를 요구하지 않는다.
    var requiresAuthorization: Bool {
        false
    }
}
