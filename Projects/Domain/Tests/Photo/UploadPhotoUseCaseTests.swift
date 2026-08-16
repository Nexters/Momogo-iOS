import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import Domain

struct UploadPhotoUseCaseTests {
    @Test("발급 -> 업로드 -> 확정을 순서대로 호출하고, 최종 응답을 반환한다")
    func execute_success_callsStepsInOrderAndReturnsResponse() async throws {
        let calledSteps = LockIsolated<[String]>([])
        let uploadedContentType = LockIsolated<String?>(nil)

        let useCase = withDependencies {
            $0.photoRepository.issueUploadURL = { request in
                calledSteps.withValue { $0.append("issueUploadURL") }
                #expect(request.contentType == "image/webp")
                return IssuePhotoUploadURLResponse(
                    uploadURL: URL(string: "https://r2.example.com/upload")!,
                    objectKey: "dev/users/1/9f8b.webp",
                    contentType: "image/webp"
                )
            }
            $0.photoRepository.upload = { _, _, contentType in
                calledSteps.withValue { $0.append("upload") }
                uploadedContentType.setValue(contentType)
            }
            $0.photoRepository.confirm = { request in
                calledSteps.withValue { $0.append("confirm") }
                #expect(request.objectKey == "dev/users/1/9f8b.webp")
                #expect(request.groupIDs == [10, 20])
                return ConfirmPhotoUploadResponse(photoId: 501, objectKey: request.objectKey)
            }
        } operation: {
            UploadPhotoUseCase.liveValue
        }

        let response = try await useCase.execute(
            UploadPhotoRequest(photoData: Data("image".utf8), contentType: "image/webp", groupIDs: [10, 20])
        )

        #expect(calledSteps.value == ["issueUploadURL", "upload", "confirm"])
        #expect(uploadedContentType.value == "image/webp")
        #expect(response.photoId == 501)
        #expect(response.objectKey == "dev/users/1/9f8b.webp")
    }

    @Test("업로드 URL 발급이 실패하면 이후 단계를 호출하지 않고 에러를 던진다")
    func execute_issueFailure_stopsBeforeUploadAndThrows() async throws {
        let uploadCalled = LockIsolated(false)

        let useCase = withDependencies {
            $0.photoRepository.issueUploadURL = { _ in throw UploadPhotoTestError.failed }
            $0.photoRepository.upload = { _, _, _ in uploadCalled.setValue(true) }
            // confirm은 호출되지 않아야 한다 — 기본 testValue(unimplemented)가 남아 있으면
            // 실수로 호출될 경우 즉시 테스트가 실패한다.
        } operation: {
            UploadPhotoUseCase.liveValue
        }

        await #expect(throws: UploadPhotoTestError.self) {
            _ = try await useCase.execute(
                UploadPhotoRequest(photoData: Data("image".utf8), contentType: "image/webp", groupIDs: [10])
            )
        }
        #expect(uploadCalled.value == false)
    }
}

private enum UploadPhotoTestError: Error {
    case failed
}
