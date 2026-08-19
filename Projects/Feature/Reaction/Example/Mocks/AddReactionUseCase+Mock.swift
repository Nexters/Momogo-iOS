import Foundation

import DomainInterface

extension AddReactionUseCase {
    private enum Constants {
        static let latencySeconds: Double = 0.4
    }

    static let happyPath = AddReactionUseCase { _ in
        try? await Task.sleep(for: .seconds(Constants.latencySeconds))
    }
}
