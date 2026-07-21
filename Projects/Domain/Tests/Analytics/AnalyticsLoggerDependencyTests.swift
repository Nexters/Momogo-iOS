import Dependencies
import DomainInterface
import XCTest

final class AnalyticsLoggerDependencyTests: XCTestCase {
    private final class StubAnalyticsLogger: AnalyticsLogging {
        private(set) var loggedEvents: [AnalyticsEvent] = []

        func log(_ event: AnalyticsEvent) {
            loggedEvents.append(event)
        }
    }

    func test_analyticsLogger_resolvesInjectedStub() {
        let stub = StubAnalyticsLogger()

        withDependencies {
            $0.analyticsLogger = stub
        } operation: {
            @Dependency(\.analyticsLogger) var logger
            logger.log(.custom(name: "test_event", parameters: ["key": "value"]))
        }

        XCTAssertEqual(stub.loggedEvents.count, 1)
    }
}
