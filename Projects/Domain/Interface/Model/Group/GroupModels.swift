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

/// 참여 코드로 그룹 정보를 확인할 때 사용하는 요청 모델.
public struct CheckGroupByCodeRequest: Sendable, Equatable {
    public let code: String

    public init(code: String) {
        self.code = code
    }
}

/// 참여 코드로 조회한 그룹 정보 응답 모델.
public struct CheckGroupByCodeResponse: Sendable, Equatable {
    public let groupId: Int
    public let groupName: String
    public let totalMemberCount: Int
    public let participated: Bool

    public init(groupId: Int, groupName: String, totalMemberCount: Int, participated: Bool) {
        self.groupId = groupId
        self.groupName = groupName
        self.totalMemberCount = totalMemberCount
        self.participated = participated
    }
}

/// 참여 코드로 그룹에 참여할 때 사용하는 요청 모델.
public struct JoinGroupByCodeRequest: Sendable, Equatable {
    public let code: String

    public init(code: String) {
        self.code = code
    }
}

/// 참여 코드로 그룹 참여 성공 시 반환되는 응답 모델.
public struct JoinGroupByCodeResponse: Sendable, Equatable {
    public let groupId: Int
    public let code: String

    public init(groupId: Int, code: String) {
        self.groupId = groupId
        self.code = code
    }
}

/// 그룹 목록의 개별 그룹 요약 정보.
public struct GroupSummary: Sendable, Equatable, Identifiable {
    public let groupId: Int
    public let groupName: String
    public let totalMemberCount: Int
    public let todayPhotoUploaderCount: Int

    public var id: Int { groupId }

    public init(
        groupId: Int,
        groupName: String,
        totalMemberCount: Int,
        todayPhotoUploaderCount: Int
    ) {
        self.groupId = groupId
        self.groupName = groupName
        self.totalMemberCount = totalMemberCount
        self.todayPhotoUploaderCount = todayPhotoUploaderCount
    }
}

/// 그룹 목록 조회 응답 모델.
public struct GetGroupsResponse: Sendable, Equatable {
    public let groups: [GroupSummary]

    public init(groups: [GroupSummary]) {
        self.groups = groups
    }
}
