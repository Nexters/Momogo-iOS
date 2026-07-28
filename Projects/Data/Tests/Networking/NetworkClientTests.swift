import Foundation
import Testing
@testable import Data

struct NetworkClientTests {
    private struct Sample: Decodable, Equatable {
        let name: String
    }

    @Test("Decodable 타입으로 정상 디코딩된다")
    func requestDecodable_validJSON_decodesSuccessfully() async throws {
        let client = NetworkClient { _ in
            Foundation.Data(#"{"name":"momogo"}"#.utf8)
        }

        let result: Sample = try await client.requestDecodable(StubTarget())

        #expect(result == Sample(name: "momogo"))
    }

    @Test("디코딩 실패 시 NetworkError.decodingFailed를 던진다")
    func requestDecodable_invalidJSON_throwsDecodingFailed() async throws {
        let client = NetworkClient { _ in
            Foundation.Data(#"{"unexpected":"field"}"#.utf8)
        }

        await #expect(throws: NetworkError.self) {
            let _: Sample = try await client.requestDecodable(StubTarget())
        }
    }
}
