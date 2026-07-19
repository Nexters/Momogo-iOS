/// 분석 이벤트를 전송하는 프로토콜.
///
/// 구체 구현(Firebase/no-op)에 의존하지 않고 이벤트 전송 계약만 표현한다.
public protocol AnalyticsLogging {
    /// 이벤트를 기록한다.
    /// - Parameter event: 전송할 이벤트.
    func log(_ event: AnalyticsEvent)
}
