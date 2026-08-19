import Foundation

import DomainInterface

extension DeletePhotoUseCase {
    private enum Constants {
        static let latencySeconds: Double = 0.4
    }

    static let happyPath = DeletePhotoUseCase { _ in
        try? await Task.sleep(for: .seconds(Constants.latencySeconds))
    }
}
