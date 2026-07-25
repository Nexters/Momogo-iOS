import Dependencies

/// `liveValue`는 여기서 채운다. `testValue`는 실제 로직이 아니라 "의도치 않은 호출을
/// 테스트에서 즉시 실패시키는 트랩"이다 — Interface 순수성 규칙의 예외.
extension AnalyticsLogging: DependencyKey {
    public static let liveValue = AnalyticsLogging(log: { event in
        FirebaseAnalyticsLogger().log(event)
    })

    public static let testValue = AnalyticsLogging(
        log: unimplemented("\(Self.self).log")
    )
}
