import Foundation

import Moya

enum GroupTargetType: NetworkTargetType {
    case create(CreateGroupRequestDTO)
    case updateName(groupId: Int, request: UpdateGroupNameRequestDTO)

    var path: String {
        switch self {
        case .create:
            "/groups"
        case let .updateName(groupId, _):
            "/groups/\(groupId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .create:
            .post
        case .updateName:
            .patch
        }
    }

    var task: Moya.Task {
        switch self {
        case let .create(dto):
            .requestJSONEncodable(dto)
        case let .updateName(_, dto):
            .requestJSONEncodable(dto)
        }
    }
}
