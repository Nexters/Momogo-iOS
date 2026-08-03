import Foundation

import Moya

enum GroupTargetType: NetworkTargetType {
    case create(CreateGroupRequestDTO)
    case updateName(groupId: Int, request: UpdateGroupNameRequestDTO)
    case checkInvitation(code: String)
    case join(JoinGroupByCodeRequestDTO)
    case list
    case detail(groupId: Int, date: String?)
    case leave(groupId: Int)

    var path: String {
        switch self {
        case .create:
            "/groups"
        case let .updateName(groupId, _):
            "/groups/\(groupId)"
        case .checkInvitation, .join:
            "/groups/invitations"
        case .list:
            "/groups"
        case let .detail(groupId, _):
            "/groups/\(groupId)"
        case let .leave(groupId):
            "/groups/\(groupId)/members/me"
        }
    }

    var method: Moya.Method {
        switch self {
        case .create, .join:
            .post
        case .updateName:
            .patch
        case .checkInvitation, .list, .detail:
            .get
        case .leave:
            .delete
        }
    }

    var task: Moya.Task {
        switch self {
        case let .create(dto):
            .requestJSONEncodable(dto)
        case let .updateName(_, dto):
            .requestJSONEncodable(dto)
        case let .checkInvitation(code):
            .requestParameters(parameters: ["code": code], encoding: URLEncoding.queryString)
        case let .join(dto):
            .requestJSONEncodable(dto)
        case .list:
            .requestPlain
        case let .detail(_, date):
            if let date {
                .requestParameters(parameters: ["date": date], encoding: URLEncoding.queryString)
            } else {
                .requestPlain
            }
        case .leave:
            .requestPlain
        }
    }
}
