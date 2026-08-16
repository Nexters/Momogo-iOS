import Foundation

import DomainInterface

extension ReportPhotoUseCase {
    static let happyPath = ReportPhotoUseCase { _ in
        try? await Task.sleep(for: .seconds(0.4))
    }
}
