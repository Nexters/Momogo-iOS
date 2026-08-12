import Foundation

/// 업로드 URL 발급을 요청할 때 사용하는 모델.
public struct IssuePhotoUploadURLRequest: Sendable, Equatable {
    public let contentType: String

    public init(contentType: String) {
        self.contentType = contentType
    }
}

/// 업로드 URL 발급 응답 모델.
public struct IssuePhotoUploadURLResponse: Sendable, Equatable {
    public let uploadURL: URL
    public let objectKey: String
    public let contentType: String

    public init(uploadURL: URL, objectKey: String, contentType: String) {
        self.uploadURL = uploadURL
        self.objectKey = objectKey
        self.contentType = contentType
    }
}

/// 업로드 확정을 요청할 때 사용하는 모델. `groupIDs`에 담긴 그룹에만 사진이 노출된다.
public struct ConfirmPhotoUploadRequest: Sendable, Equatable {
    public let objectKey: String
    public let groupIDs: [Int]

    public init(objectKey: String, groupIDs: [Int]) {
        self.objectKey = objectKey
        self.groupIDs = groupIDs
    }
}

/// 업로드 확정 응답 모델.
public struct ConfirmPhotoUploadResponse: Sendable, Equatable {
    public let photoId: Int
    public let objectKey: String

    public init(photoId: Int, objectKey: String) {
        self.photoId = photoId
        self.objectKey = objectKey
    }
}

/// 사진 업로드(발급 → 직접 업로드 → 확정) 전체 플로우를 요청할 때 사용하는 모델.
public struct UploadPhotoRequest: Sendable, Equatable {
    public let photoData: Data
    public let contentType: String
    public let groupIDs: [Int]

    public init(photoData: Data, contentType: String, groupIDs: [Int]) {
        self.photoData = photoData
        self.contentType = contentType
        self.groupIDs = groupIDs
    }
}

/// 사진 업로드 전체 플로우 완료 후 반환되는 모델.
public struct UploadPhotoResponse: Sendable, Equatable {
    public let photoId: Int
    public let objectKey: String

    public init(photoId: Int, objectKey: String) {
        self.photoId = photoId
        self.objectKey = objectKey
    }
}
