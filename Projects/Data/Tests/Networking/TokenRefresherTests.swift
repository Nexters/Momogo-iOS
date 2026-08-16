import Foundation
import Testing
@testable import Data

struct TokenRefresherTests {
    @Test("재발급이 성공하면 클로저가 정확히 한 번 호출된다")
    func refreshIfNeeded_success_callsRefreshOnce() async throws {
        let callCount = Locked(0)
        let refresher = TokenRefresher {
            callCount.set(callCount.get() + 1)
        }

        try await refresher.refreshIfNeeded()

        #expect(callCount.get() == 1)
    }

    @Test("동시에 여러 번 호출해도 재발급 호출은 한 번만 나간다(single-flight)")
    func refreshIfNeeded_concurrentCalls_coalescesIntoSingleRefresh() async throws {
        let callCount = Locked(0)
        let refresher = TokenRefresher {
            callCount.set(callCount.get() + 1)
            try await Task.sleep(for: .milliseconds(50))
        }

        async let first: Void = refresher.refreshIfNeeded()
        async let second: Void = refresher.refreshIfNeeded()
        async let third: Void = refresher.refreshIfNeeded()
        _ = try await (first, second, third)

        #expect(callCount.get() == 1)
    }

    @Test("재발급 실패 시 동시에 기다리던 호출도 모두 실패한다")
    func refreshIfNeeded_failure_propagatesErrorToAllWaiters() async throws {
        struct SampleError: Error {}
        let refresher = TokenRefresher {
            try await Task.sleep(for: .milliseconds(30))
            throw SampleError()
        }

        async let first = resultOfRefresh(refresher)
        async let second = resultOfRefresh(refresher)
        let results = await (first, second)

        #expect(results.0 == false)
        #expect(results.1 == false)
    }

    @Test("이전 재발급이 끝난 뒤 다시 호출하면 새 재발급이 나간다")
    func refreshIfNeeded_afterPreviousCompletes_triggersNewRefresh() async throws {
        let callCount = Locked(0)
        let refresher = TokenRefresher {
            callCount.set(callCount.get() + 1)
        }

        try await refresher.refreshIfNeeded()
        try await refresher.refreshIfNeeded()

        #expect(callCount.get() == 2)
    }

    private func resultOfRefresh(_ refresher: TokenRefresher) async -> Bool {
        do {
            try await refresher.refreshIfNeeded()
            return true
        } catch {
            return false
        }
    }
}
