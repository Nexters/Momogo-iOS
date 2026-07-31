import Foundation
import Testing
import Moya
@testable import Data

struct GroupTargetTypeTests {
    @Test("create는 POST /groups")
    func create_hasCorrectRouting() {
        let target = GroupTargetType.create(CreateGroupRequestDTO(groupName: "우리 가족"))

        #expect(target.path == "/groups")
        #expect(target.method == .post)
    }

    @Test("updateName은 PATCH /groups/{groupId}")
    func updateName_hasCorrectRouting() {
        let target = GroupTargetType.updateName(groupId: 10, request: UpdateGroupNameRequestDTO(groupName: "새 이름"))

        #expect(target.path == "/groups/10")
        #expect(target.method == .patch)
    }

    @Test("checkInvitation은 GET /groups/invitations, code 쿼리 파라미터")
    func checkInvitation_hasCorrectRouting() {
        let target = GroupTargetType.checkInvitation(code: "A1B2C3D4")

        #expect(target.path == "/groups/invitations")
        #expect(target.method == .get)
    }

    @Test("list는 GET /groups, requestPlain")
    func list_hasCorrectRouting() {
        let target = GroupTargetType.list

        #expect(target.path == "/groups")
        #expect(target.method == .get)
        guard case .requestPlain = target.task else {
            Issue.record("requestPlain을 기대했지만 다른 task가 반환됨")
            return
        }
    }

    @Test("detail은 date가 nil이면 requestPlain으로 라우팅된다")
    func detail_nilDate_usesRequestPlain() {
        let target = GroupTargetType.detail(groupId: 10, date: nil)

        #expect(target.path == "/groups/10")
        #expect(target.method == .get)
        guard case .requestPlain = target.task else {
            Issue.record("requestPlain을 기대했지만 다른 task가 반환됨")
            return
        }
    }

    @Test("detail은 date가 있으면 쿼리 파라미터로 라우팅된다")
    func detail_withDate_usesQueryParameters() {
        let target = GroupTargetType.detail(groupId: 10, date: "2026-07-25")

        guard case .requestParameters = target.task else {
            Issue.record("requestParameters를 기대했지만 다른 task가 반환됨")
            return
        }
    }
}
