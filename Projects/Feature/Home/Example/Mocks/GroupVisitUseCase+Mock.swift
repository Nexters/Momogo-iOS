import Foundation

import Dependencies
import DomainInterface

/// `GetGroupVisitsUseCase`/`MarkGroupVisitedUseCase` 한 쌍이 같은 인메모리 저장소를 공유하게 해,
/// 카드 탭 → 방문 기록 → 배지 소멸까지 실제 판정 로직(`GroupSummary.hasNewPhoto`) 그대로 데모에서 확인할 수
/// 있게 한다. 시나리오(피커 선택)마다 새 인스턴스를 만들어 이전 탭 상태가 다른 시나리오로 새지 않게 한다.
///
/// Example 앱은 Data 모듈을 링크하지 않아 실제 liveValue(UserDefaults 영속화)를 쓸 수 없으므로, 이 mock은
/// 프로세스 메모리에만 남는다 — 앱을 재실행하면 초기화되어 시나리오를 반복 확인할 수 있다.
final class GroupVisitMockStore: @unchecked Sendable {
    private let storage: LockIsolated<[Int: String]>

    init(seed: [Int: String] = [:]) {
        storage = LockIsolated(seed)
    }

    var getUseCase: GetGroupVisitsUseCase {
        GetGroupVisitsUseCase { [storage] in storage.value }
    }

    var markUseCase: MarkGroupVisitedUseCase {
        // liveValue와 동일한 규칙: latestUploadAt이 nil이면 기존 기록을 지우지 않는다.
        MarkGroupVisitedUseCase { [storage] groupId, latestUploadAt in
            guard let latestUploadAt else { return }
            storage.withValue { $0[groupId] = latestUploadAt }
        }
    }
}
