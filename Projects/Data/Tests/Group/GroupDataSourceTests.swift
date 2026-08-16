import Dependencies
import Foundation
import Testing
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
                {"groupId":10,"groupName":"우리 가족","inviteCode":"ABC123","createdAt":"2026-08-01T09:00:00.123456",
                "date":"2026-08-05","members":[{"userId":1,"nickname":"엄마","mine":true,"photo":null}]}
                """#.utf8)
            }
        } operation: {
            GroupDataSource.liveValue
        }

        let response = try await dataSource.detail(10, nil)

        #expect(response.groupId == 10)
        #expect(response.members.map(\.nickname) == ["엄마"])
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

    @Test("사진 신고 성공 시 에러 없이 완료된다")
    func reportPhoto_success_completesWithoutThrowing() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in Foundation.Data("{}".utf8) }
        } operation: {
            GroupDataSource.liveValue
        }

        try await dataSource.reportPhoto(10, 501, PhotoReportRequestDTO(reason: "부적절한 사진이 포함되어 있습니다."))
    }

    @Test("사진 내리기 성공 시 에러 없이 완료된다")
    func unlinkPhoto_success_completesWithoutThrowing() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in Foundation.Data("{}".utf8) }
        } operation: {
            GroupDataSource.liveValue
        }

        try await dataSource.unlinkPhoto(10, 501)
    }
}
