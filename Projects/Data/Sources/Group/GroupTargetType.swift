import Foundation

import Moya

enum GroupTargetType: NetworkTargetType {
    case create(CreateGroupRequestDTO)
    case updateName(groupId: Int, request: UpdateGroupNameRequestDTO)
    case checkInvitation(code: String)
    case list
    case detail(groupId: Int, date: String?)

    var path: String {
        switch self {
        case .create:
            "/groups"
        case let .updateName(groupId, _):
            "/groups/\(groupId)"
        case .checkInvitation:
            "/groups/invitations"
        case .list:
            "/groups"
        case let .detail(groupId, _):
            "/groups/\(groupId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .create:
            .post
        case .updateName:
            .patch
        case .checkInvitation, .list, .detail:
            .get
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
        case .list:
            .requestPlain
        case let .detail(_, date):
            if let date {
                .requestParameters(parameters: ["date": date], encoding: URLEncoding.queryString)
            } else {
                .requestPlain
            }
        }
    }
}
