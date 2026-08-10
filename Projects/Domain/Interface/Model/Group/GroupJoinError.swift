import Foundation

/// 초대코드로 그룹에 참여하는 과정에서 서버가 내려주는 실패 사유.
/// Feature는 DomainInterface만 의존해 NetworkError를 볼 수 없으므로, 이 타입으로 승격시켜 전달한다.
/// 초대코드 조회(checkGroupByCode)와 참여(joinGroupByCode) 양쪽에서 발생한다.
public enum GroupJoinError: Error, Equatable, Sendable {
    /// 유효하지 않은 초대코드 (404 INVALID_INVITATION_CODE)
    case invalidInvitationCode
    /// 이미 참여 중인 그룹 (409 ALREADY_JOINED)
    case alreadyJoined
    /// 그룹 정원 초과 (409 GROUP_FULL)
    case groupFull
}
