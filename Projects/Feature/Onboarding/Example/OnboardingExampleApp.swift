import SwiftUI

import Dependencies
import DomainInterface

@main
struct OnboardingExampleApp: App {
    init() {
        prepareDependencies {
            $0.createGroupUseCase = .happyPath
            $0.checkGroupByCodeUseCase = .happyPath
            $0.joinGroupByCodeUseCase = .happyPath
        }
    }

    var body: some Scene {
        WindowGroup {
            OnboardingExampleRootView()
        }
    }
}
