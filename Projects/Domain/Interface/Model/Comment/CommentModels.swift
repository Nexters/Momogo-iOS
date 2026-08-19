import Foundation

/// 리액션 문구 카탈로그의 콘셉트. 서버 스펙상 현재 콘셉트는 이 하나뿐이다 — `ReactionMode.oldCrack`/
/// `.nagging`(늙크크/잔소리)은 아직 서버에 대응 콘셉트가 없는 클라이언트 전용 '이후 버전' 표시다.
public enum CommentConcept: String, Sendable, Equatable {
    case youngCreatorCrew = "YOUNG_CREATOR_CREW"
}

/// 리액션 문구 카탈로그의 이모지. `ReactionEmoji`(drool/hot/money/thinking)와 1:1 대응한다.
public enum CommentEmoji: String, Sendable, Equatable {
    case delicious = "DELICIOUS"
    case hot = "HOT"
    case flex = "FLEX"
    case hmm = "HMM"
}

/// 콘셉트×이모지 조합 하나에 속한 문구 후보 목록.
public struct CommentSet: Sendable, Equatable {
    public let concept: CommentConcept
    public let emoji: CommentEmoji
    public let contents: [String]

    public init(concept: CommentConcept, emoji: CommentEmoji, contents: [String]) {
        self.concept = concept
        self.emoji = emoji
        self.contents = contents
    }
}

/// `GET /init/comments` 응답을 도메인으로 옮긴 문구 카탈로그.
public struct CommentCatalog: Sendable, Equatable {
    /// 문구 전체의 최종 수정 시각(Asia/Seoul). 등록된 문구가 없으면 nil.
    public let revision: String?
    public let sets: [CommentSet]

    public init(revision: String?, sets: [CommentSet]) {
        self.revision = revision
        self.sets = sets
    }

    /// 이 콘셉트×이모지 조합의 문구 후보. 없으면 빈 배열.
    public func contents(concept: CommentConcept, emoji: CommentEmoji) -> [String] {
        sets.first { $0.concept == concept && $0.emoji == emoji }?.contents ?? []
    }

    /// revision이 없거나(=서버에 등록된 문구가 없음) 문구가 하나도 없으면 신뢰하지 않는다.
    public var isUsable: Bool {
        revision != nil && !sets.isEmpty
    }
}
