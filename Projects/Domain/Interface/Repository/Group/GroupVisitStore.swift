import Foundation

import Dependencies

/// 그룹별 "마지막으로 봤을 때의 latestUploadAt 스냅샷"을 저장하는 로컬 저장소 포트. 실제 구현은 Data 모듈에서 제공한다.
/// New 배지 판정(`GroupSummary.hasNewPhoto`)은 이 스냅샷과 서버가 내려준 최신값을 비교해서 이뤄진다.
public struct GroupVisitStore: Sendable {
    /// groupId → 마지막으로 본 시점의 latestUploadAt 스냅샷. 방문 기록이 없는 그룹은 딕셔너리에 없다.
    public var lastSeenUploadAt: @Sendable () -> [Int: String]
    /// 그룹을 방문했음을 기록한다. `latestUploadAt`이 nil이면(활성 사진 없음) 기존 기록을 지우지 않고 그대로 둔다.
    public var markSeen: @Sendable (Int, String?) -> Void

    public init(
        lastSeenUploadAt: @escaping @Sendable () -> [Int: String],
        markSeen: @escaping @Sendable (Int, String?) -> Void
    ) {
        self.lastSeenUploadAt = lastSeenUploadAt
        self.markSeen = markSeen
    }
}

extension GroupVisitStore: TestDependencyKey {
    public static let testValue = GroupVisitStore(
        lastSeenUploadAt: unimplemented("\(Self.self).lastSeenUploadAt", placeholder: [:]),
        markSeen: unimplemented("\(Self.self).markSeen")
    )
}

public extension DependencyValues {
    var groupVisitStore: GroupVisitStore {
        get { self[GroupVisitStore.self] }
        set { self[GroupVisitStore.self] = newValue }
    }
}
