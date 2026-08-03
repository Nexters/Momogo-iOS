import SwiftUI

import FeatureOnboarding
import FirebaseCore

@main
struct MomogoApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            OnboardingView(viewModel: OnboardingViewModel())
        }
    }
}
