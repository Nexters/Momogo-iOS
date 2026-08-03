import Foundation
import Testing
import Dependencies
@testable import Data

struct GroupDataSourceTests {
    @Test("그룹 생성 성공 시 응답을 반환한다")
    func create_success_returnsResponse() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"{"groupId":10,"groupName":"우리 가족","inviteCode":"A1B2C3D4"}"#.utf8)
            }
        } operation: {
            GroupDataSource.liveValue
        }

        let response = try await dataSource.create(CreateGroupRequestDTO(name: "우리 가족"))

        #expect(response.groupId == 10)
        #expect(response.inviteCode == "A1B2C3D4")
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
            _ = try await dataSource.create(CreateGroupRequestDTO(name: "우리 가족"))
        }
    }

    @Test("참여 코드로 그룹 정보 확인 성공 시 응답을 반환한다")
    func checkInvitation_success_returnsResponse() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"{"groupId":10,"groupName":"우리 가족","totalMemberCount":4,"participated":false}"#.utf8)
            }
        } operation: {
            GroupDataSource.liveValue
        }

        let response = try await dataSource.checkInvitation("A1B2C3D4")

        #expect(response.participated == false)
    }

    @Test("참여 그룹 목록 조회 성공 시 빈 배열도 정상 디코딩된다")
    func list_success_decodesEmptyArray() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in Foundation.Data(#"{"groups":[]}"#.utf8) }
        } operation: {
            GroupDataSource.liveValue
        }

        let response = try await dataSource.list()

        #expect(response.groups.isEmpty)
    }

    @Test("그룹 상세 조회 성공 시 응답을 반환한다")
    func detail_success_returnsResponse() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"""
                {"date":"2026-07-25 14:30:00.123456+00","todayVerifiedCount":2,"totalMemberCount":4,
                "invitationCode":"A1B2C3D4","members":[]}
                """#.utf8)
            }
        } operation: {
            GroupDataSource.liveValue
        }

        let response = try await dataSource.detail(10, nil)

        #expect(response.todayVerifiedCount == 2)
    }

    @Test("그룹 나가기 성공 시 에러 없이 완료된다")
    func leave_success_completesWithoutThrowing() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in Foundation.Data() }
        } operation: {
            GroupDataSource.liveValue
        }

        try await dataSource.leave(10)
    }
}
