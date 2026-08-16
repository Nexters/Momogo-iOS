import Testing
@testable import Analytics

struct AnalyticsLoggerTests {
    /// 테스트 전용 no-op 로거. `AnalyticsLogging.testValue`(unimplemented)는 호출 시 실패하므로
    /// "크래시 없이 종료" 시나리오를 검증하려면 이 테스트 타겟에서 직접 실제 동작하는 값을 만든다.
    private let logger = AnalyticsLogging(log: { event in
        switch event {
        case let .custom(name, parameters):
            AnalyticsEvent.warnIfInvalidParameters(parameters, eventName: name)
            print("📊 [AnalyticsLoggerTests] event: \(name), parameters: \(parameters)")
        }
    })

    @Test("허용 타입(String/Bool/Int/Double)만 담은 parameters로 log(_:) 호출 시 크래시 없이 종료된다")
    func noOpLogger_allowedParameterTypes_doesNotCrash() {
        let parameters: [String: Any] = [
            "string": "value",
            "bool": true,
            "int": 1,
            "double": 1.0
        ]

        logger.log(.custom(name: "test_event", parameters: parameters))
    }

    @Test("허용 타입 밖 값(예: [Int] 배열)을 담은 parameters로 log(_:) 호출 시 경고만 남기고 크래시 없이 종료된다 (AD-6)")
    func noOpLogger_disallowedParameterTypes_doesNotCrash() {
        let parameters: [String: Any] = [
            "arr": [1, 2, 3]
        ]

        logger.log(.custom(name: "test_event", parameters: parameters))
    }
}
