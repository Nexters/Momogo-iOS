import Foundation
import Moya
import Testing
@testable import Data

struct ReactionTargetTypeTests {
    @Test("add는 POST /groups/{groupId}/members/{memberId}/reactions, 인증 필요")
    func add_hasCorrectRouting() {
        let target = ReactionTargetType.add(
            groupId: 10, memberId: 1, request: AddReactionRequestDTO(type: "HEART", comment: nil, date: "2026-07-25")
        )

        #expect(target.path == "/groups/10/members/1/reactions")
        #expect(target.method == .post)
        #expect(target.requiresAuthorization == true)
    }

    @Test("page는 GET, date가 nil이면 requestPlain으로 라우팅된다")
    func page_nilDate_usesRequestPlain() {
        let target = ReactionTargetType.page(groupId: 10, memberId: 1, date: nil)

        #expect(target.path == "/groups/10/members/1/reactions")
        #expect(target.method == .get)
        guard case .requestPlain = target.task else {
            Issue.record("requestPlain을 기대했지만 다른 task가 반환됨")
            return
        }
    }
}
