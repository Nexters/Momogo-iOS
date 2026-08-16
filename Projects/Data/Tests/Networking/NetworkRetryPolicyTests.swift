import Foundation
import Moya
import Testing
@testable import Data

struct NetworkRetryPolicyTests {
    @Test("오프라인 등 연결 자체가 실패한 경우는 재시도 대상이다")
    func isRetryable_connectivityError_returnsTrue() {
        let error = MoyaError.underlying(URLError(.notConnectedToInternet), nil)

        #expect(NetworkRetryPolicy.isRetryable(error))
    }

    @Test("타임아웃도 재시도 대상이다")
    func isRetryable_timeout_returnsTrue() {
        let error = MoyaError.underlying(URLError(.timedOut), nil)

        #expect(NetworkRetryPolicy.isRetryable(error))
    }

    @Test("서버가 응답한 상태 코드 에러는 재시도 대상이 아니다")
    func isRetryable_statusCodeError_returnsFalse() {
        let response = Response(statusCode: 500, data: Foundation.Data())
        let error = MoyaError.statusCode(response)

        #expect(!NetworkRetryPolicy.isRetryable(error))
    }

    @Test("재시도 대상이 아닌 URLError 코드는 재시도하지 않는다")
    func isRetryable_nonRetryableURLErrorCode_returnsFalse() {
        let error = MoyaError.underlying(URLError(.badURL), nil)

        #expect(!NetworkRetryPolicy.isRetryable(error))
    }

    @Test("재시도 횟수가 늘어날수록 대기 시간도 늘어난다")
    func delay_increasesWithAttempt() {
        #expect(NetworkRetryPolicy.delay(forAttempt: 1) > NetworkRetryPolicy.delay(forAttempt: 0))
    }
}
