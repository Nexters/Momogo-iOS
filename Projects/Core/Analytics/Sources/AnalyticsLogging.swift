/// 분석 이벤트를 전송하는 포트.
///
/// 구체 구현(Firebase/테스트용 stub 등)에 의존하지 않고 이벤트 전송 계약만 표현한다.
public struct AnalyticsLogging: Sendable {
    public var log: @Sendable (AnalyticsEvent) -> Void

    public init(log: @escaping @Sendable (AnalyticsEvent) -> Void) {
        self.log = log
    }
}
