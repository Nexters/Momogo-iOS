import Dependencies
import Foundation
import Testing
@testable import Data

struct ReactionDataSourceTests {
    @Test("반응 추가 성공 시 응답을 반환한다")
    func add_success_returnsResponse() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"""
                {
                  "groupId": 10,
                  "member": { "id": 1, "nickname": "엄마" },
                  "reactions": [{ "type": "HEART", "comment": "예쁘다", "memberId": 2, "nickname": "아빠" }],
                  "reactionCounts": [{ "type": "HEART", "count": 1 }]
                }
                """#.utf8)
            }
        } operation: {
            ReactionDataSource.liveValue
        }

        let response = try await dataSource.add(
            10, 1, AddReactionRequestDTO(type: "HEART", comment: "예쁘다", date: "2026-07-25 14:30:00.123456+00")
        )

        #expect(response.groupId == 10)
        #expect(response.reactionCounts.first?.count == 1)
    }

    @Test("응답 디코딩 실패 시 decodingFailed를 던진다")
    func add_invalidJSON_throwsDecodingFailed() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in Foundation.Data(#"{"unexpected":"field"}"#.utf8) }
        } operation: {
            ReactionDataSource.liveValue
        }

        await #expect(throws: NetworkError.self) {
            _ = try await dataSource.add(
                10, 1, AddReactionRequestDTO(type: "HEART", comment: nil, date: "2026-07-25 14:30:00.123456+00")
            )
        }
    }

    @Test("반응 페이지 조회 성공 시 응답을 반환한다")
    func page_success_returnsResponse() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"""
                {"groupId":10,"member":{"id":1,"nickname":"엄마"},
                "reactions":[{"type":"HEART","comment":"예쁘다","memberId":2,"nickname":"아빠",
                "createdAt":"2026-07-25T14:30:00+09:00"}],
                "reactionCounts":[{"type":"HEART","count":1}]}
                """#.utf8)
            }
        } operation: {
            ReactionDataSource.liveValue
        }

        let response = try await dataSource.page(10, 1, "2026-07-25")

        #expect(response.reactions.first?.createdAt == "2026-07-25T14:30:00+09:00")
    }
}
