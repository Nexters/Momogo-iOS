import SwiftUI

import Dependencies
import DomainInterface
import FeatureOnboarding

@main
struct OnboardingExampleApp: App {
    init() {
        prepareDependencies {
            $0.signUpUseCase = .happyPath
        }
    }

    var body: some Scene {
        WindowGroup {
            OnboardingView(viewModel: OnboardingViewModel())
        }
    }
}
