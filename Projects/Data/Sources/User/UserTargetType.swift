import Foundation

import Moya

enum UserTargetType: NetworkTargetType {
    case register(RegisterRequestDTO)
    case update(UpdateUserRequestDTO)
    case delete

    var path: String {
        switch self {
        case .register:
            "/user/register"
        case .update, .delete:
            "/user"
        }
    }

    var method: Moya.Method {
        switch self {
        case .register:
            .post
        case .update:
            .patch
        case .delete:
            .delete
        }
    }

    var task: Moya.Task {
        switch self {
        case let .register(dto):
            .requestJSONEncodable(dto)
        case let .update(dto):
            .requestJSONEncodable(dto)
        case .delete:
            .requestPlain
        }
    }

    var requiresAuthorization: Bool {
        switch self {
        case .register:
            false
        default:
            true
        }
    }
}
