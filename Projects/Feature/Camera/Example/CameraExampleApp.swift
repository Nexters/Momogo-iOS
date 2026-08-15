import SwiftUI

import Dependencies
import DomainInterface
import FeatureCamera
import FeaturePhoto

@main
struct CameraExampleApp: App {
    init() {
        // 실제 앱(FeatureHome)에서 촬영 완료 후 이어지는 그룹 선택/업로드 화면까지 Example에서
        // 재현하기 위한 Mock. FeaturePhoto/Example의 동일한 Mock과 내용을 맞췄다.
        prepareDependencies {
            $0.getGroupsUseCase = .happyPath
            $0.uploadPhotoUseCase = .happyPath
        }
    }

    var body: some Scene {
        WindowGroup {
            CameraExampleRootView()
        }
    }
}

/// 실제 앱(HomeView)과 동일한 순서로 화면을 전환한다: 카메라 fullScreenCover가 완전히 닫힌 뒤에야
/// 업로드 확인(그룹 선택) fullScreenCover를 띄운다. 두 cover를 동시에 전환하면 애니메이션이
/// 깨질 수 있어서다.
private struct CameraExampleRootView: View {
    @State private var isCameraPresented = true
    @State private var pendingPhotoData: Data?
    @State private var photoUploadConfirmViewModel: PhotoUploadConfirmViewModel?

    var body: some View {
        VStack(spacing: 16) {
            Text("촬영을 마치면 그룹 선택 화면으로 이동합니다")
                .foregroundStyle(.secondary)

            Button("카메라 열기") {
                isCameraPresented = true
            }
        }
        .fullScreenCover(
            isPresented: $isCameraPresented,
            onDismiss: { presentPhotoUploadConfirmIfNeeded() },
            content: {
                CameraView(viewModel: CameraViewModel(onFinish: { photoData in
                    pendingPhotoData = photoData
                    isCameraPresented = false
                }))
            }
        )
        .fullScreenCover(
            isPresented: Binding(
                get: { photoUploadConfirmViewModel != nil },
                set: { isPresented in if !isPresented { photoUploadConfirmViewModel = nil } }
            ),
            content: {
                if let photoUploadConfirmViewModel {
                    PhotoUploadConfirmView(viewModel: photoUploadConfirmViewModel)
                }
            }
        )
    }

    private func presentPhotoUploadConfirmIfNeeded() {
        guard let photoData = pendingPhotoData else { return }
        pendingPhotoData = nil

        photoUploadConfirmViewModel = PhotoUploadConfirmViewModel(
            photoData: photoData,
            onCancel: { photoUploadConfirmViewModel = nil },
            onUploaded: { photoUploadConfirmViewModel = nil }
        )
    }
}
