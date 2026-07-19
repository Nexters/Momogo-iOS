import Core
import Dependencies

public typealias AnalyticsEvent = Core.AnalyticsEvent
public typealias AnalyticsLogging = Core.AnalyticsLogging

extension DependencyValues {
    public var analyticsLogger: AnalyticsLogging {
        get { self[AnalyticsLoggerKey.self] }
        set { self[AnalyticsLoggerKey.self] = newValue }
    }
}
