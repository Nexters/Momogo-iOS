/// Core 레이어에서 사용하는 분석 이벤트 모델.
///
/// 구체 구현(Firebase/no-op 등)과 무관하게 이벤트 전송 계약을 표현한다.
/// 임시 Event -> 기획 의견 반영 후 수정 예정
public enum AnalyticsEvent {
    /// 커스텀 이벤트.
    /// - Parameters:
    ///   - name: 이벤트 이름.
    ///   - parameters: 이벤트 파라미터. 값으로 담을 수 있는 타입은 `String`, `Bool`, `Int`, `Double`로 제한된다.
    case custom(name: String, parameters: [String: Any])
}

public extension AnalyticsEvent {
    /// 허용되지 않은 파라미터 타입이 있으면 콘솔에 경고를 남긴다.
    ///
    /// 허용 타입(`String`/`Bool`/`Int`/`Double`) 제약은 컴파일 타임에 강제되지 않으므로,
    /// 런타임에 로깅 구현체들이 공통으로 사용할 수 있는 검증 헬퍼로 제공한다.
    static func warnIfInvalidParameters(_ parameters: [String: Any], eventName: String) {
        for (key, value) in parameters {
            switch value {
            case is String, is Bool, is Int, is Double:
                continue
            default:
                print(
                    "⚠️ [AnalyticsEvent] 허용되지 않은 파라미터 타입 - event: \(eventName), "
                        + "key: \(key), type: \(type(of: value))"
                )
            }
        }
    }
}
