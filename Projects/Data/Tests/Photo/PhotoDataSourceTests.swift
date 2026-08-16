import ConcurrencyExtras
import Dependencies
import Foundation
import Testing
@testable import Data

struct PhotoDataSourceTests {
    @Test("업로드 URL 발급 성공 시 응답을 반환한다")
    func issueUploadURL_success_returnsResponse() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"""
                {
                  "uploadUrl": "https://r2.example.com/momogo/dev/users/1/9f8b.webp",
                  "objectKey": "dev/users/1/2026-08-03/9f8b3a1c2.webp",
                  "contentType": "image/webp",
                  "expiresAt": "2026-08-03T18:15:00"
                }
                """#.utf8)
            }
        } operation: {
            PhotoDataSource.liveValue
        }

        let response = try await dataSource
            .issueUploadURL(PhotoUploadUrlRequestDTO(contentType: "image/webp"))

        #expect(response.objectKey == "dev/users/1/2026-08-03/9f8b3a1c2.webp")
        #expect(response.uploadUrl == "https://r2.example.com/momogo/dev/users/1/9f8b.webp")
    }

    @Test("업로드 확정 성공 시 응답을 반환한다")
    func confirm_success_returnsResponse() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in
                Foundation.Data(#"""
                {"photoId":501,"objectKey":"dev/users/1/2026-08-03/9f8b3a1c2.webp",
                "createdAt":"2026-08-03T14:30:00.123456"}
                """#.utf8)
            }
        } operation: {
            PhotoDataSource.liveValue
        }

        let response = try await dataSource.confirm(
            PhotoCreateRequestDTO(objectKey: "dev/users/1/2026-08-03/9f8b3a1c2.webp", groupIds: [10, 20])
        )

        #expect(response.photoId == 501)
    }

    @Test("응답 디코딩 실패 시 decodingFailed를 던진다")
    func issueUploadURL_invalidJSON_throwsDecodingFailed() async throws {
        let dataSource = withDependencies {
            $0.networkClient = NetworkClient { _ in Foundation.Data(#"{"unexpected":"field"}"#.utf8) }
        } operation: {
            PhotoDataSource.liveValue
        }

        await #expect(throws: NetworkError.self) {
            _ = try await dataSource.issueUploadURL(PhotoUploadUrlRequestDTO(contentType: "image/webp"))
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

        let targetURL = URL(string: "https://r2.example.com/momogo/dev/users/1/9f8b.webp")!
        try await dataSource.upload(targetURL, Foundation.Data("image".utf8), "image/webp")

        #expect(uploadedURL.value == targetURL)
    }
}
