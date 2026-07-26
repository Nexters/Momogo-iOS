import Dependencies

public extension DependencyValues {
    var analyticsLogger: AnalyticsLogging {
        get { self[AnalyticsLogging.self] }
        set { self[AnalyticsLogging.self] = newValue }
    }
}
