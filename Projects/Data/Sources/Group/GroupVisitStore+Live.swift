import Foundation

import Dependencies

import DomainInterface

/// UserDefaults에 그룹 방문 스냅샷을 저장한다. 프로젝트 첫 UserDefaults 사용처라 민감정보가 아닌 값에 한해 쓴다
/// (토큰류는 기존 Keychain 패턴을 그대로 따른다).
private enum GroupVisitDefaults {
    static let key = "momogo.group.lastSeenUploadAt"

    /// 여러 그룹 화면이 동시에 읽고 쓸 수 있어, UserDefaults 읽기-수정-쓰기 구간을 락으로 감싼다.
    /// `RefreshTokenStore`의 lock 패턴을 그대로 따른다.
    private static let lock = NSLock()

    static func read() -> [Int: String] {
        lock.lock()
        defer { lock.unlock() }
        guard let stored = UserDefaults.standard.dictionary(forKey: key) as? [String: String] else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: stored.compactMap { key, value in
            Int(key).map { ($0, value) }
        })
    }

    static func markSeen(groupId: Int, latestUploadAt: String?) {
        // 활성 사진이 없는 시점(nil)에 방문해도 과거 기록을 지우지 않는다. 사진이 삭제됐다가 다시
        // 올라오는 경우에도 "그 전에 어디까지 봤는지" 판단 기준이 유지되어야 한다.
        guard let latestUploadAt else { return }

        lock.lock()
        defer { lock.unlock() }
        var stored = (UserDefaults.standard.dictionary(forKey: key) as? [String: String]) ?? [:]
        stored[String(groupId)] = latestUploadAt
        UserDefaults.standard.set(stored, forKey: key)
    }
}

extension GroupVisitStore: DependencyKey {
    public static let liveValue = GroupVisitStore(
        lastSeenUploadAt: { GroupVisitDefaults.read() },
        markSeen: { groupId, latestUploadAt in
            GroupVisitDefaults.markSeen(groupId: groupId, latestUploadAt: latestUploadAt)
        }
    )
}
