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
