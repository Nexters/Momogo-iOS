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
    public let members: [GroupMember]
    /// 오늘 이 그룹에 내가 이미 활성 사진을 올렸는지 여부. 정책상 사진을 지우기 전까지는 같은
    /// 그룹에 다시 업로드할 수 없어, 업로드 대상 그룹을 고를 때 이 값으로 선택 가능 여부를 가른다.
    public let todayPhotoUploaded: Bool

    public var id: Int { groupId }

    public init(
        groupId: Int,
        groupName: String,
        totalMemberCount: Int,
        todayPhotoUploaderCount: Int,
        members: [GroupMember] = [],
        todayPhotoUploaded: Bool = false
    ) {
        self.groupId = groupId
        self.groupName = groupName
        self.totalMemberCount = totalMemberCount
        self.todayPhotoUploaderCount = todayPhotoUploaderCount
        self.members = members
        self.todayPhotoUploaded = todayPhotoUploaded
    }
}

/// 그룹 목록 조회 응답 모델.
public struct GetGroupsResponse: Sendable, Equatable {
    public let groups: [GroupSummary]

    public init(groups: [GroupSummary]) {
        self.groups = groups
    }
}

/// 그룹 상세를 조회할 때 사용하는 요청 모델.
public struct GetGroupDetailRequest: Sendable, Equatable {
    public let groupId: Int
    /// 조회할 날짜(yyyy-MM-dd). nil이면 서버가 오늘(Asia/Seoul) 기준으로 조회한다.
    public let date: String?

    public init(groupId: Int, date: String? = nil) {
        self.groupId = groupId
        self.date = date
    }
}

/// 그룹 상세의 그룹원과 선택 날짜의 사진. 서버가 "나 → 닉네임순"으로 정렬해서 내려준다.
public struct GroupMember: Sendable, Equatable, Identifiable {
    public let userId: Int
    public let nickname: String
    public let isMine: Bool
    public let photo: GroupMemberPhoto?

    public var id: Int { userId }

    public init(userId: Int, nickname: String, isMine: Bool, photo: GroupMemberPhoto? = nil) {
        self.userId = userId
        self.nickname = nickname
        self.isMine = isMine
        self.photo = photo
    }
}

/// 그룹원이 선택 날짜에 올린 사진.
public struct GroupMemberPhoto: Sendable, Equatable {
    public let photoId: Int
    public let downloadUrl: String

    public init(photoId: Int, downloadUrl: String) {
        self.photoId = photoId
        self.downloadUrl = downloadUrl
    }
}

/// 그룹 상세 조회 응답 모델.
public struct GetGroupDetailResponse: Sendable, Equatable {
    public let groupId: Int
    public let groupName: String
    public let members: [GroupMember]

    public init(groupId: Int, groupName: String, members: [GroupMember]) {
        self.groupId = groupId
        self.groupName = groupName
        self.members = members
    }
}

/// 그룹명 변경 요청 모델.
public struct UpdateGroupNameRequest: Sendable, Equatable {
    public let groupId: Int
    public let groupName: String

    public init(groupId: Int, groupName: String) {
        self.groupId = groupId
        self.groupName = groupName
    }
}

/// 그룹명 변경 성공 시 반환되는 응답 모델.
public struct UpdateGroupNameResponse: Sendable, Equatable {
    public let groupId: Int
    public let groupName: String

    public init(groupId: Int, groupName: String) {
        self.groupId = groupId
        self.groupName = groupName
    }
}

/// 그룹 탈퇴 요청 모델.
public struct LeaveGroupRequest: Sendable, Equatable {
    public let groupId: Int

    public init(groupId: Int) {
        self.groupId = groupId
    }
}

/// 사진 신고 요청 모델.
public struct ReportPhotoRequest: Sendable, Equatable {
    public let groupId: Int
    public let photoId: Int
    public let reason: String

    public init(groupId: Int, photoId: Int, reason: String) {
        self.groupId = groupId
        self.photoId = photoId
        self.reason = reason
    }
}

/// 그룹에서 사진을 내리는(삭제하는) 요청 모델. 내가 올린 사진만 내릴 수 있다.
public struct DeletePhotoRequest: Sendable, Equatable {
    public let groupId: Int
    public let photoId: Int

    public init(groupId: Int, photoId: Int) {
        self.groupId = groupId
        self.photoId = photoId
    }
}
