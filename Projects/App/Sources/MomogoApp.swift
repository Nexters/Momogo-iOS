import SwiftUI

import DomainInterface
import FeatureHome
import FeatureOnboarding
import FeatureSplash
import FirebaseCore

@main
struct MomogoApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

private struct RootView: View {
    private enum RootDestination {
        case splash
        case home
        case onboarding
    }
    @State private var destination: RootDestination = .splash

    var body: some View {
        switch destination {
        case .splash:
            SplashView(viewModel: SplashViewModel(onFinish: { splashDestination in
                switch splashDestination {
                case .home:
                    destination = .home
                case .onboarding:
                    destination = .onboarding
                }
            }))
        case .home:
            HomeView(viewModel: HomeViewModel(onLogout: { destination = .onboarding }))
        case .onboarding:
            OnboardingView(viewModel: OnboardingViewModel(onFinish: { destination = .home }))
        }
    }
}
