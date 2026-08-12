import SwiftUI

import Dependencies
import DomainInterface
import FeaturePhoto

@main
struct PhotoExampleApp: App {
    init() {
        prepareDependencies {
            $0.getGroupsUseCase = .happyPath
            $0.getGroupDetailUseCase = .happyPath
            $0.uploadPhotoUseCase = .happyPath
        }
    }

    var body: some Scene {
        WindowGroup {
            PhotoUploadConfirmView(
                viewModel: PhotoUploadConfirmViewModel(
                    photoData: .mockPhoto,
                    onCancel: {},
                    onUploaded: {}
                )
            )
        }
    }
}
