import Foundation

import Moya

enum ReactionTargetType: NetworkTargetType {
    /// photoId 기반 경로. `GroupTargetType`의 사진 API들(`/groups/{groupId}/photos/{photoId}/...`)과
    /// 같은 경로 규약을 따른다 — memberId 기반이었던 과거 스텁은 한 번도 연결된 적 없는 죽은 코드였다.
    case add(groupId: Int, photoId: Int, request: AddReactionRequestDTO)
    /// 등록과 같은 경로, GET. 과거 memberId 기반 `page` 스텁(한 번도 연결된 적 없는 죽은 코드)을 대체한다.
    case list(groupId: Int, photoId: Int)

    var path: String {
        switch self {
        case let .add(groupId, photoId, _), let .list(groupId, photoId):
            "/groups/\(groupId)/photos/\(photoId)/reactions"
        }
    }

    var method: Moya.Method {
        switch self {
        case .add:
            .post
        case .list:
            .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .add(_, _, dto):
            .requestJSONEncodable(dto)
        case .list:
            .requestPlain
        }
    }
}
