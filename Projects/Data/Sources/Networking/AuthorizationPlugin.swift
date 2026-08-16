import Foundation

import Moya

/// `requiresAuthorization`이 true인 요청에 `Authorization: Bearer {token}` 헤더를 자동으로 붙인다.
struct AuthorizationPlugin: PluginType {
    let tokenStore: AccessTokenStore

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        let underlyingTarget = (target as? MultiTarget)?.target ?? target
        guard
            let networkTarget = underlyingTarget as? any NetworkTargetType,
            networkTarget.requiresAuthorization,
            let token = tokenStore.current()
        else {
            return request
        }

        var request = request
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
