import Foundation
import Moya
import Testing
@testable import Data

struct RequestRetryTests {
    private struct AuthorizedStub: NetworkTargetType {
        var path: String { "/stub" }
        var method: Moya.Method { .get }
        var task: Moya.Task { .requestPlain }
    }

    private struct UnauthorizedStub: NetworkTargetType {
        var requiresAuthorization: Bool { false }
        var path: String { "/stub" }
        var method: Moya.Method { .get }
        var task: Moya.Task { .requestPlain }
    }

    @Test("인증이 필요한 요청이 401을 받으면 재발급 대상이다")
    func isUnauthorized_requiresAuthorizationWith401_returnsTrue() {
        let response = Response(statusCode: 401, data: Foundation.Data())
        let error = MoyaError.statusCode(response)

        #expect(isUnauthorized(error, target: AuthorizedStub()))
    }

    @Test("인증이 필요 없는 요청은 401이어도 재발급 대상이 아니다(무한 루프 방지)")
    func isUnauthorized_doesNotRequireAuthorization_returnsFalse() {
        let response = Response(statusCode: 401, data: Foundation.Data())
        let error = MoyaError.statusCode(response)

        #expect(!isUnauthorized(error, target: UnauthorizedStub()))
    }

    @Test("401이 아닌 상태 코드는 재발급 대상이 아니다")
    func isUnauthorized_non401StatusCode_returnsFalse() {
        let response = Response(statusCode: 403, data: Foundation.Data())
        let error = MoyaError.statusCode(response)

        #expect(!isUnauthorized(error, target: AuthorizedStub()))
    }
}
