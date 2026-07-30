import Foundation

import Moya

enum PhotoTargetType: NetworkTargetType {
    case createUploadSession(CreateUploadSessionRequestDTO)
    case confirm(ConfirmUploadRequestDTO)

    var path: String {
        switch self {
        case .createUploadSession:
            "/photos/upload-sessions"
        case .confirm:
            "/photos"
        }
    }

    var method: Moya.Method {
        .post
    }

    var task: Moya.Task {
        switch self {
        case let .createUploadSession(dto):
            .requestJSONEncodable(dto)
        case let .confirm(dto):
            .requestJSONEncodable(dto)
        }
    }
}
