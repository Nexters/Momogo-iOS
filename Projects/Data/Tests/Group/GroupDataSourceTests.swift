import Foundation
import Testing
import Dependencies
@testable import Data

struct GroupDataSourceTests {
    @Test("그룹 생성 성공 시 응답을 반환한다")
    func create_success_returnsResponse() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"{"groupId":10,"groupName":"우리 가족","invitationCode":"A1B2C3D4"}"#.utf8)
            }
        } operation: {
            GroupDataSource.liveValue
        }

        let response = try await dataSource.create(CreateGroupRequestDTO(groupName: "우리 가족"))

        #expect(response.groupId == 10)
        #expect(response.invitationCode == "A1B2C3D4")
    }

    @Test("그룹명 변경 성공 시 응답을 반환한다")
    func updateName_success_returnsResponse() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"{"groupId":10,"groupName":"우리 가족 하우스"}"#.utf8)
            }
        } operation: {
            GroupDataSource.liveValue
        }

        let response = try await dataSource.updateName(10, UpdateGroupNameRequestDTO(groupName: "우리 가족 하우스"))

        #expect(response.groupName == "우리 가족 하우스")
    }

    @Test("응답 디코딩 실패 시 decodingFailed를 던진다")
    func create_invalidJSON_throwsDecodingFailed() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in Foundation.Data(#"{"unexpected":"field"}"#.utf8) }
        } operation: {
            GroupDataSource.liveValue
        }

        await #expect(throws: NetworkError.self) {
            _ = try await dataSource.create(CreateGroupRequestDTO(groupName: "우리 가족"))
        }
    }
}
