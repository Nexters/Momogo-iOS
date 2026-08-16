import SwiftUI

import Dependencies
import DomainInterface
import FeatureOnboarding

@main
struct OnboardingExampleApp: App {
    init() {
        prepareDependencies {
            $0.signUpUseCase = .happyPath
            $0.createGroupUseCase = .happyPath
            $0.checkGroupByCodeUseCase = .happyPath
            $0.joinGroupByCodeUseCase = .happyPath
        }
    }

    var body: some Scene {
        WindowGroup {
            OnboardingView(viewModel: OnboardingViewModel())
        }
    }
}
