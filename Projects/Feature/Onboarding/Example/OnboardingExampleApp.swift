import SwiftUI

import Dependencies
import DomainInterface
import FeatureOnboarding

@main
struct OnboardingExampleApp: App {
    init() {
        prepareDependencies {
            $0.groupClient = .happyPath
        }
    }

    var body: some Scene {
        WindowGroup {
            OnboardingView(viewModel: OnboardingViewModel())
        }
    }
}
