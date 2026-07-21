import Dependencies

/// `AnalyticsLogging`을 swift-dependencies의 `DependencyKey`로 등록한다.
public enum AnalyticsLoggerKey: DependencyKey {
    public static let liveValue: AnalyticsLogging = FirebaseAnalyticsLogger()
    public static let testValue: AnalyticsLogging = NoOpAnalyticsLogger()
    public static let previewValue: AnalyticsLogging = NoOpAnalyticsLogger()
}

/// 유닛 테스트/프리뷰에서 사용하는 no-op `AnalyticsLogging` 구현체.
///
/// `previewValue`는 Xcode Preview 캔버스(앱 프로세스)에서도 쓰이므로 `CoreTests` 타겟이 아닌
/// `Core` 소스에 위치해야 한다 — 순수 assertion용 테스트 mock이 아니라 DependencyKey 계약의
/// 일부(swift-dependencies 관례)다.
private struct NoOpAnalyticsLogger: AnalyticsLogging {
    func log(_ event: AnalyticsEvent) {
        switch event {
        case let .custom(name, parameters):
            AnalyticsEvent.warnIfInvalidParameters(parameters, eventName: name)
            print("📊 [NoOpAnalyticsLogger] event: \(name), parameters: \(parameters)")
        }
    }
}
