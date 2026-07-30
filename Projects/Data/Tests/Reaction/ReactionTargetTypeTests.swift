import Foundation
import Testing
import Moya
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
}
