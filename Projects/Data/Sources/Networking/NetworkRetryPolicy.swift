import Foundation

import Moya

/// 네트워크 연결 문제(오프라인, 타임아웃 등)로 요청이 실패했을 때 재시도할지 판단하는 정책.
/// 서버가 명확히 응답한 상태 코드 에러(4xx/5xx)는 대상이 아니다.
enum NetworkRetryPolicy {
    /// 최초 시도 이후 추가로 재시도할 최대 횟수.
    static let maxRetryCount = 2

    /// attempt번째 재시도 전에 대기할 시간. 재시도할수록 선형으로 늘어난다(0.5s, 1s, ...).
    static func delay(forAttempt attempt: Int) -> Duration {
        .milliseconds(500 * (attempt + 1))
    }

    /// 서버 응답 없이 연결 자체가 실패한 경우에만 재시도 대상으로 본다.
    static func isRetryable(_ error: MoyaError) -> Bool {
        guard case let .underlying(underlyingError, response) = error, response == nil else {
            return false
        }
        guard let urlError = underlyingError as? URLError else {
            return false
        }
        switch urlError.code {
        case .notConnectedToInternet,
             .networkConnectionLost,
             .timedOut,
             .cannotConnectToHost,
             .cannotFindHost,
             .dnsLookupFailed,
             .dataNotAllowed:
            return true
        default:
            return false
        }
    }
}
