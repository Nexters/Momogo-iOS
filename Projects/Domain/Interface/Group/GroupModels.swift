import Foundation

/// 그룹을 생성할 때 사용하는 요청 모델.
public struct CreateGroupRequest: Sendable, Equatable {
    public let groupName: String

    public init(groupName: String) {
        self.groupName = groupName
    }
}

/// 그룹 생성 성공 시 반환되는 응답 모델.
public struct CreateGroupResponse: Sendable, Equatable {
    public let groupId: Int
    public let groupName: String
    public let invitationCode: String

    public init(groupId: Int, groupName: String, invitationCode: String) {
        self.groupId = groupId
        self.groupName = groupName
        self.invitationCode = invitationCode
    }
}
