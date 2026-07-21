import Dependencies
import Foundation

public struct GroupClient {
    public var createGroup: (_ name: String) async throws -> GroupInfo
    public var fetchGroupInfo: (_ inviteCode: String) async throws -> GroupInfo
    public var joinGroup: (_ inviteCode: String) async throws -> GroupInfo

    public init(
        createGroup: @escaping (_ name: String) async throws -> GroupInfo,
        fetchGroupInfo: @escaping (_ inviteCode: String) async throws -> GroupInfo,
        joinGroup: @escaping (_ inviteCode: String) async throws -> GroupInfo
    ) {
        self.createGroup = createGroup
        self.fetchGroupInfo = fetchGroupInfo
        self.joinGroup = joinGroup
    }
}

extension GroupClient: TestDependencyKey {
    public static let testValue = GroupClient.happyPath
}

public extension GroupClient {
    /// 실제 API 연동 전까지 사용하는 happy path 목 구현. 0.3초 지연 후 항상 성공값을 반환한다.
    static let happyPath = GroupClient(
        createGroup: { name in
            try await Task.sleep(for: .seconds(0.3))
            return GroupInfo(id: UUID().uuidString, name: name, inviteCode: "A1B2C3")
        },
        fetchGroupInfo: { inviteCode in
            try await Task.sleep(for: .seconds(0.3))
            return GroupInfo(id: UUID().uuidString, name: "모모네 가족", inviteCode: inviteCode)
        },
        joinGroup: { inviteCode in
            try await Task.sleep(for: .seconds(0.3))
            return GroupInfo(id: UUID().uuidString, name: "모모네 가족", inviteCode: inviteCode)
        }
    )
}

public extension DependencyValues {
    var groupClient: GroupClient {
        get { self[GroupClient.self] }
        set { self[GroupClient.self] = newValue }
    }
}
