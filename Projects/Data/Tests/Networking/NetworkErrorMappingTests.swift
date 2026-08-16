import Foundation
import Moya
import Testing
@testable import Data

struct NetworkErrorMappingTests {
    @Test("problem+json 바디를 ProblemDetail로 디코딩한다")
    func mapToNetworkError_problemJSONBody_decodesProblemDetail() throws {
        let body = Foundation.Data("""
        {"type":"about:blank","title":"Bad Request","status":400,"detail":"INVALID_GROUP_NAME","instance":"/groups"}
        """.utf8)
        let response = Response(statusCode: 400, data: body)

        let result = mapToNetworkError(.statusCode(response))

        guard case let .serverError(statusCode, problem) = result else {
            Issue.record("serverError를 기대했지만 \(result)가 반환됨")
            return
        }
        #expect(statusCode == 400)
        #expect(problem?.detail == "INVALID_GROUP_NAME")
    }

    @Test("401은 problem이 있어도 unauthorized로 매핑된다")
    func mapToNetworkError_401_mapsToUnauthorized() throws {
        let body = Foundation.Data("""
        {"type":"about:blank","title":"Unauthorized","status":401,"detail":"UNAUTHORIZED","instance":"/groups"}
        """.utf8)
        let response = Response(statusCode: 401, data: body)

        let result = mapToNetworkError(.statusCode(response))

        guard case let .unauthorized(problem) = result else {
            Issue.record("unauthorized를 기대했지만 \(result)가 반환됨")
            return
        }
        #expect(problem?.detail == "UNAUTHORIZED")
    }

    @Test("problem+json이 아닌 바디는 problem이 nil로 폴백된다")
    func mapToNetworkError_nonProblemBody_fallsBackToNilProblem() throws {
        let response = Response(statusCode: 500, data: Foundation.Data("Internal Server Error".utf8))

        let result = mapToNetworkError(.statusCode(response))

        guard case let .serverError(statusCode, problem) = result else {
            Issue.record("serverError를 기대했지만 \(result)가 반환됨")
            return
        }
        #expect(statusCode == 500)
        #expect(problem == nil)
    }

    @Test("일부 필드(type/instance)가 없어도 title/status/detail은 디코딩된다")
    func mapToNetworkError_missingOptionalFields_stillDecodesRequiredFields() throws {
        let body = Foundation.Data("""
        {"title":"Bad Request","status":400,"detail":"INVALID_GROUP_NAME"}
        """.utf8)
        let response = Response(statusCode: 400, data: body)

        let result = mapToNetworkError(.statusCode(response))

        guard case let .serverError(statusCode, problem) = result else {
            Issue.record("serverError를 기대했지만 \(result)가 반환됨")
            return
        }
        #expect(statusCode == 400)
        #expect(problem?.detail == "INVALID_GROUP_NAME")
        #expect(problem?.type == nil)
        #expect(problem?.instance == nil)
    }
}
