import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import Domain

struct GetGroupDetailUseCaseTests {
    @Test("Repository의 그룹 상세 응답을 그대로 반환한다")
    func execute_success_returnsResponse() async throws {
        let useCase = withDependencies {
            $0.groupRepository.getGroupDetail = { request in
                #expect(request.groupId == 10)
                return GetGroupDetailResponse(
                    groupId: 10,
                    groupName: "우리 가족",
                    members: [
                        GroupMember(userId: 1, nickname: "엄마", isMine: true),
                        GroupMember(userId: 2, nickname: "아빠", isMine: false)
                    ]
                )
            }
        } operation: {
            GetGroupDetailUseCase.liveValue
        }

        let response = try await useCase.execute(GetGroupDetailRequest(groupId: 10))

        #expect(response.members.map(\.nickname) == ["엄마", "아빠"])
    }

    @Test("Repository가 실패하면 에러를 그대로 던진다")
    func execute_repositoryFailure_throws() async throws {
        let useCase = withDependencies {
            $0.groupRepository.getGroupDetail = { _ in throw GetGroupDetailTestError.failed }
        } operation: {
            GetGroupDetailUseCase.liveValue
        }

        await #expect(throws: GetGroupDetailTestError.self) {
            _ = try await useCase.execute(GetGroupDetailRequest(groupId: 10))
        }
    }
}

private enum GetGroupDetailTestError: Error {
    case failed
}
