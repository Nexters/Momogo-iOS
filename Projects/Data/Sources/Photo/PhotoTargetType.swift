import Foundation

import Moya

enum PhotoTargetType: NetworkTargetType {
    case issueUploadURL(PhotoUploadUrlRequestDTO)
    case confirm(PhotoCreateRequestDTO)
    case myPhotos(date: String?)

    var path: String {
        switch self {
        case .issueUploadURL:
            "/photos/upload-urls"
        case .confirm:
            "/photos"
        case .myPhotos:
            "/photos/me"
        }
    }

    var method: Moya.Method {
        switch self {
        case .issueUploadURL, .confirm:
            .post
        case .myPhotos:
            .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .issueUploadURL(dto):
            .requestJSONEncodable(dto)
        case let .confirm(dto):
            .requestJSONEncodable(dto)
        case let .myPhotos(date):
            if let date {
                .requestParameters(parameters: ["date": date], encoding: URLEncoding.queryString)
            } else {
                .requestPlain
            }
        }
    }
}
