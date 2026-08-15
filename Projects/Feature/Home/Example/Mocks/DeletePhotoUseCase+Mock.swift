import Foundation

import DomainInterface

extension DeletePhotoUseCase {
    static let happyPath = DeletePhotoUseCase { _ in
        try? await Task.sleep(for: .seconds(0.4))
    }
}
