import Foundation

import Moya

enum ReactionTargetType: NetworkTargetType {
    case add(groupId: Int, memberId: Int, request: AddReactionRequestDTO)

    var path: String {
        switch self {
        case let .add(groupId, memberId, _):
            "/groups/\(groupId)/members/\(memberId)/reactions"
        }
    }

    var method: Moya.Method {
        switch self {
        case .add:
            .post
        }
    }

    var task: Moya.Task {
        switch self {
        case let .add(_, _, dto):
            .requestJSONEncodable(dto)
        }
    }
}
