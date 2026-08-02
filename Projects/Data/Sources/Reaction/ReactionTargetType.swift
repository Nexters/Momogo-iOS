import Foundation

import Moya

enum ReactionTargetType: NetworkTargetType {
    case add(groupId: Int, memberId: Int, request: AddReactionRequestDTO)
    case page(groupId: Int, memberId: Int, date: String?)

    var path: String {
        switch self {
        case let .add(groupId, memberId, _):
            "/groups/\(groupId)/members/\(memberId)/reactions"
        case let .page(groupId, memberId, _):
            "/groups/\(groupId)/members/\(memberId)/reactions"
        }
    }

    var method: Moya.Method {
        switch self {
        case .add:
            .post
        case .page:
            .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .add(_, _, dto):
            .requestJSONEncodable(dto)
        case let .page(_, _, date):
            if let date {
                .requestParameters(parameters: ["date": date], encoding: URLEncoding.queryString)
            } else {
                .requestPlain
            }
        }
    }
}
