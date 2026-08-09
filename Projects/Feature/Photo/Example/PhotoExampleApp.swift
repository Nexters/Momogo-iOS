import SwiftUI

import FeaturePhoto

@main
struct PhotoExampleApp: App {
    var body: some Scene {
        WindowGroup {
            PhotoUploadConfirmView(
                viewModel: PhotoUploadConfirmViewModel(
                    photoData: .mockPhoto,
                    groups: PhotoUploadGroupOption.mockOptions,
                    onCancel: {},
                    onConfirm: { _, _ in }
                )
            )
        }
    }
}
