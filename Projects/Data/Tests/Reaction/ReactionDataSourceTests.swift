import Dependencies
import Foundation
import Testing
@testable import Data

struct ReactionDataSourceTests {
    @Test("반응 추가 성공 시 응답 파싱 없이 완료된다")
    func add_success_doesNotThrow() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in Foundation.Data() }
        } operation: {
            ReactionDataSource.liveValue
        }

        try await dataSource.add(
            10,
            7,
            AddReactionRequestDTO(concept: "YOUNG_CREATOR_CREW", emoji: "DELICIOUS", comment: "야르~")
        )
    }

    @Test("서버 에러는 그대로 전파된다")
    func add_serverError_throws() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in throw NetworkError.serverError(statusCode: 400, problem: nil) }
        } operation: {
            ReactionDataSource.liveValue
        }

        await #expect(throws: NetworkError.self) {
            try await dataSource.add(
                10,
                7,
                AddReactionRequestDTO(concept: "YOUNG_CREATOR_CREW", emoji: "DELICIOUS", comment: "야르~")
            )
        }
    }

    @Test("반응 목록 조회 성공 시 응답을 반환한다")
    func list_success_returnsResponse() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"""
                {"photoId":7,"groupId":10,"reactions":[{
                    "reactionId":901,"userId":2,"nickname":"길동",
                    "concept":"YOUNG_CREATOR_CREW","emoji":"DELICIOUS","comment":"야르~",
                    "createdAt":"2026-08-08T14:30:00.123456","mine":false
                }]}
                """#.utf8)
            }
        } operation: {
            ReactionDataSource.liveValue
        }

        let response = try await dataSource.list(10, 7)

        #expect(response.reactions.first?.reactionId == 901)
        #expect(response.reactions.first?.mine == false)
    }
}
