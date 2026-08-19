import Foundation

import Dependencies

import DomainInterface

/// UserDefaults에 리액션 문구 카탈로그를 저장한다. `GroupVisitStore+Live`가 이 프로젝트의 첫
/// UserDefaults 사용처를 열었고, 이 파일이 두 번째다(민감정보가 아닌 값에 한해 사용, 토큰류는
/// 기존 Keychain 패턴을 따른다).
private enum CommentCatalogDefaults {
    static let key = "momogo.comment.catalog.v1"

    /// 온디스크 스키마. `CommentCatalog`(Domain 모델)를 그대로 Codable로 만들지 않고 별도로 두는
    /// 이유는, 스키마가 Domain 타입 리팩터링에 끌려다니면 프로퍼티 이름 하나 바꿔도 전 사용자
    /// 캐시가 조용히 무효화되기 때문이다. concept/emoji는 rawValue(String)로 저장해, 미래에
    /// enum 케이스가 늘어도 과거에 저장된 값의 디코딩이 실패하지 않게 한다.
    private struct Record: Codable {
        struct SetRecord: Codable {
            let concept: String
            let emoji: String
            let contents: [String]
        }

        let revision: String?
        let sets: [SetRecord]
    }

    /// 여러 화면이 동시에 읽고 쓸 수 있어(스플래시의 백그라운드 동기화 vs 반응 화면의 읽기),
    /// UserDefaults 읽기/쓰기 구간을 락으로 감싼다. `RefreshTokenStore`의 lock 패턴을 그대로 따른다.
    private static let lock = NSLock()

    static func read() -> CommentCatalog? {
        lock.lock()
        defer { lock.unlock() }

        guard
            let data = UserDefaults.standard.data(forKey: key),
            let record = try? JSONDecoder().decode(Record.self, from: data)
        else { return nil }

        let sets = record.sets.compactMap { setRecord -> CommentSet? in
            guard
                let concept = CommentConcept(rawValue: setRecord.concept),
                let emoji = CommentEmoji(rawValue: setRecord.emoji)
            else { return nil }
            return CommentSet(concept: concept, emoji: emoji, contents: setRecord.contents)
        }
        return CommentCatalog(revision: record.revision, sets: sets)
    }

    static func write(_ catalog: CommentCatalog) {
        let record = Record(
            revision: catalog.revision,
            sets: catalog.sets.map {
                Record.SetRecord(concept: $0.concept.rawValue, emoji: $0.emoji.rawValue, contents: $0.contents)
            }
        )
        guard let data = try? JSONEncoder().encode(record) else { return }

        lock.lock()
        defer { lock.unlock() }
        UserDefaults.standard.set(data, forKey: key)
    }
}

extension CommentCatalogStore: DependencyKey {
    public static let liveValue = CommentCatalogStore(
        load: { CommentCatalogDefaults.read() },
        save: { CommentCatalogDefaults.write($0) }
    )
}
