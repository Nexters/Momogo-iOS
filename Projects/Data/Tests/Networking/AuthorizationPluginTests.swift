import Foundation
import Testing

import Moya

@testable import Data

struct StubTarget: NetworkTargetType {
    var requiresAuthorization: Bool = true

    var path: String { "/stub" }
    var method: Moya.Method { .get }
    var task: Moya.Task { .requestPlain }
}

struct AuthorizationPluginTests {
    @Test("토큰이 있고 인증이 필요하면 Authorization 헤더를 붙인다")
    func prepare_requiresAuthorizationWithToken_addsHeader() {
        let store = AccessTokenStore(token: "abc123")
        let plugin = AuthorizationPlugin(tokenStore: store)
        let request = URLRequest(url: URL(string: "https://example.com")!)

        let prepared = plugin.prepare(request, target: MultiTarget(StubTarget()))

        #expect(prepared.value(forHTTPHeaderField: "Authorization") == "Bearer abc123")
    }

    @Test("requiresAuthorization이 false면 헤더를 붙이지 않는다")
    func prepare_doesNotRequireAuthorization_doesNotAddHeader() {
        let store = AccessTokenStore(token: "abc123")
        let plugin = AuthorizationPlugin(tokenStore: store)
        var target = StubTarget()
        target.requiresAuthorization = false
        let request = URLRequest(url: URL(string: "https://example.com")!)

        let prepared = plugin.prepare(request, target: MultiTarget(target))

        #expect(prepared.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test("토큰이 없으면 헤더를 붙이지 않는다")
    func prepare_noToken_doesNotAddHeader() {
        let store = AccessTokenStore(token: nil)
        let plugin = AuthorizationPlugin(tokenStore: store)
        let request = URLRequest(url: URL(string: "https://example.com")!)

        let prepared = plugin.prepare(request, target: MultiTarget(StubTarget()))

        #expect(prepared.value(forHTTPHeaderField: "Authorization") == nil)
    }
}
