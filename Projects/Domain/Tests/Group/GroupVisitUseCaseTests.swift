import Testing

import Dependencies
import DomainInterface

@testable import Domain

/// `GroupVisitStore`의 실제 구현(Data 모듈, UserDefaults)은 여기서 쓰지 않는다. 로컬 저장을 실제로
/// 건드리지 않도록 `groupVisitStore`를 테스트 더블로 주입해, UseCase가 Store에 올바르게 위임하는지만 검증한다.
struct GroupVisitUseCaseTests {
    @Test("GetGroupVisitsUseCase는 Store의 방문 스냅샷을 그대로 반환한다")
    func getGroupVisits_returnsStoreSnapshot() {
        let snapshot = [10: "2026-08-10T14:30:00.123456", 11: "2026-08-01T00:00:00.000000"]

        let useCase = withDependencies {
            $0.groupVisitStore.lastSeenUploadAt = { snapshot }
        } operation: {
            GetGroupVisitsUseCase.liveValue
        }

        #expect(useCase.execute() == snapshot)
    }

    @Test("MarkGroupVisitedUseCase는 groupId와 latestUploadAt을 Store에 그대로 전달한다")
    func markGroupVisited_forwardsArgumentsToStore() {
        let captured = Locked<(groupId: Int, latestUploadAt: String?)?>(nil)

        let useCase = withDependencies {
            $0.groupVisitStore.markSeen = { groupId, latestUploadAt in
                captured.set((groupId, latestUploadAt))
            }
        } operation: {
            MarkGroupVisitedUseCase.liveValue
        }

        useCase.execute(10, "2026-08-10T14:30:00.123456")

        #expect(captured.get()?.groupId == 10)
        #expect(captured.get()?.latestUploadAt == "2026-08-10T14:30:00.123456")
    }

    @Test("MarkGroupVisitedUseCase는 latestUploadAt이 nil이어도 Store에 nil 그대로 전달한다")
    func markGroupVisited_withNilLatestUploadAt_forwardsNil() {
        let captured = Locked<(groupId: Int, latestUploadAt: String?)?>(nil)

        let useCase = withDependencies {
            $0.groupVisitStore.markSeen = { groupId, latestUploadAt in
                captured.set((groupId, latestUploadAt))
            }
        } operation: {
            MarkGroupVisitedUseCase.liveValue
        }

        useCase.execute(11, nil)

        #expect(captured.get()?.groupId == 11)
        #expect(captured.get()?.latestUploadAt == nil)
    }
}
