import Foundation
import Testing
import Dependencies
import ConcurrencyExtras
@testable import Data

struct PhotoDataSourceTests {
    @Test("Presigned URL 발급 성공 시 응답을 반환한다")
    func createUploadSession_success_returnsResponse() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"""
                {
                  "uploadSessionId": 3001,
                  "uploadUrl": "https://minio.example.com/momogo/users/1/9f8b.webp",
                  "objectKey": "users/1/2026-07-25/9f8b3a1c2.webp",
                  "expiresAt": "2026-07-25T18:15:00+09:00"
                }
                """#.utf8)
            }
        } operation: {
            PhotoDataSource.liveValue
        }

        let response = try await dataSource
            .createUploadSession(CreateUploadSessionRequestDTO(contentType: "image/webp"))

        #expect(response.uploadSessionId == 3001)
        #expect(response.objectKey == "users/1/2026-07-25/9f8b3a1c2.webp")
    }

    @Test("업로드 확정 성공 시 응답을 반환한다")
    func confirm_success_returnsResponse() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"""
                {"photoId":501,"objectKey":"users/1/2026-07-25/9f8b3a1c2.webp",
                "uploadDate":"2026-07-25 14:30:00.123456+00"}
                """#.utf8)
            }
        } operation: {
            PhotoDataSource.liveValue
        }

        let response = try await dataSource.confirm(ConfirmUploadRequestDTO(uploadSessionId: 3001))

        #expect(response.photoId == 501)
    }

    @Test("응답 디코딩 실패 시 decodingFailed를 던진다")
    func createUploadSession_invalidJSON_throwsDecodingFailed() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in Foundation.Data(#"{"unexpected":"field"}"#.utf8) }
        } operation: {
            PhotoDataSource.liveValue
        }

        await #expect(throws: NetworkError.self) {
            _ = try await dataSource.createUploadSession(CreateUploadSessionRequestDTO(contentType: "image/webp"))
        }
    }

    @Test("upload는 주입된 MediaUploadClient에 위임한다")
    func upload_delegatesToMediaUploadClient() async throws {
        let uploadedURL = LockIsolated<URL?>(nil)
        let dataSource = withDependencies {
            $0.mediaUploadClient = MediaUploadClient { url, _, _ in
                uploadedURL.setValue(url)
            }
        } operation: {
            PhotoDataSource.liveValue
        }

        let targetURL = URL(string: "https://minio.example.com/momogo/users/1/9f8b.webp")!
        try await dataSource.upload(targetURL, Foundation.Data("image".utf8), "image/webp")

        #expect(uploadedURL.value == targetURL)
    }
}
