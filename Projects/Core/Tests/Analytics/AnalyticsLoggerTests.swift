import Testing
@testable import Core

struct AnalyticsLoggerTests {
    @Test("허용 타입(String/Bool/Int/Double)만 담은 parameters로 log(_:) 호출 시 크래시 없이 종료된다")
    func noOpLogger_allowedParameterTypes_doesNotCrash() {
        let logger = AnalyticsLoggerKey.testValue
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
        let logger = AnalyticsLoggerKey.testValue
        let parameters: [String: Any] = [
            "arr": [1, 2, 3]
        ]

        logger.log(.custom(name: "test_event", parameters: parameters))
    }
}
