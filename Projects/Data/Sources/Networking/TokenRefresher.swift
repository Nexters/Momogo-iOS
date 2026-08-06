import Foundation

/// 여러 요청이 동시에 401을 받아도 accessToken 재발급 호출은 한 번만 나가도록 묶는다(single-flight).
/// 실제 재발급 방법(HTTP 호출, 토큰 저장)은 알지 못하고 `refresh` 클로저에 위임한다.
actor TokenRefresher {
    private let refresh: @Sendable () async throws -> Void
    private var inFlightTask: Task<Void, Error>?

    init(refresh: @escaping @Sendable () async throws -> Void) {
        self.refresh = refresh
    }

    /// accessToken을 재발급받는다. 이미 진행 중인 재발급이 있다면 새로 요청을 보내지 않고 그 결과를 공유한다.
    func refreshIfNeeded() async throws {
        if let inFlightTask {
            try await inFlightTask.value
            return
        }

        let task = Task { try await self.refresh() }
        inFlightTask = task
        defer { inFlightTask = nil }
        try await task.value
    }
}
