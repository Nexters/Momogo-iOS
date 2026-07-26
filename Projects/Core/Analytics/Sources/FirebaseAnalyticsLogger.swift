import FirebaseAnalytics

/// Firebase Analytics로 이벤트를 전송하는 구현체.
public struct FirebaseAnalyticsLogger: Sendable {
    public init() {}

    public func log(_ event: AnalyticsEvent) {
        switch event {
        case let .custom(name, parameters):
            AnalyticsEvent.warnIfInvalidParameters(parameters, eventName: name)
            Analytics.logEvent(name, parameters: parameters)
        }
    }
}
