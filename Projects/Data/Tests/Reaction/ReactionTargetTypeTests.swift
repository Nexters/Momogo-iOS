import Foundation
import Moya
import Testing
@testable import Data

struct ReactionTargetTypeTests {
    @Test("add는 POST /groups/{groupId}/photos/{photoId}/reactions, 인증 필요")
    func add_hasCorrectRouting() {
        let target = ReactionTargetType.add(
            groupId: 10, photoId: 7,
            request: AddReactionRequestDTO(concept: "YOUNG_CREATOR_CREW", emoji: "DELICIOUS", comment: "야르~")
        )

        #expect(target.path == "/groups/10/photos/7/reactions")
        #expect(target.method == .post)
        #expect(target.requiresAuthorization == true)
    }

    @Test("list는 GET /groups/{groupId}/photos/{photoId}/reactions, requestPlain으로 라우팅된다")
    func list_hasCorrectRouting() {
        let target = ReactionTargetType.list(groupId: 10, photoId: 7)

        #expect(target.path == "/groups/10/photos/7/reactions")
        #expect(target.method == .get)
        guard case .requestPlain = target.task else {
            Issue.record("requestPlain을 기대했지만 다른 task가 반환됨")
            return
        }
    }
}
