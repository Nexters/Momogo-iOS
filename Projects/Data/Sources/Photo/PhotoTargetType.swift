import Foundation

import Moya

enum PhotoTargetType: NetworkTargetType {
    case issueUploadURL(PhotoUploadUrlRequestDTO)
    case confirm(PhotoCreateRequestDTO)

    var path: String {
        switch self {
        case .issueUploadURL:
            "/photos/upload-urls"
        case .confirm:
            "/photos"
        }
    }

    var method: Moya.Method {
        .post
    }

    var task: Moya.Task {
        switch self {
        case let .issueUploadURL(dto):
            .requestJSONEncodable(dto)
        case let .confirm(dto):
            .requestJSONEncodable(dto)
        }
    }
}
