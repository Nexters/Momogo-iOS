import Foundation

import DomainInterface

extension LeaveGroupUseCase {
    static let happyPath = LeaveGroupUseCase { _ in
        try? await Task.sleep(for: .seconds(0.4))
    }
}
