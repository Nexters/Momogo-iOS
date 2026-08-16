import Foundation

import Moya

enum AuthTargetType: NetworkTargetType {
    case login(LoginRequestDTO)
    case reissue(ReissueRequestDTO)
    case logout(LogoutRequestDTO)

    var path: String {
        switch self {
        case .login:
            "/auth/login"
        case .reissue:
            "/auth/reissue"
        case .logout:
            "/auth/logout"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login, .reissue:
            .post
        case .logout:
            .delete
        }
    }

    var task: Moya.Task {
        switch self {
        case let .login(dto):
            .requestJSONEncodable(dto)
        case let .reissue(dto):
            .requestJSONEncodable(dto)
        case let .logout(dto):
            .requestJSONEncodable(dto)
        }
    }

    var requiresAuthorization: Bool {
        switch self {
        case .login, .reissue:
            false
        case .logout:
            true
        }
    }
}
