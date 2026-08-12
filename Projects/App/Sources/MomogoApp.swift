import SwiftUI

import DesignSystem
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
    @State private var toast: DSTopToastContent?

    var body: some View {
        Group {
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
                HomeView(viewModel: HomeViewModel(
                    onLogout: { destination = .onboarding },
                    onGroupJoined: { toast = $0 }
                ))
            case .onboarding:
                OnboardingView(viewModel: OnboardingViewModel(onFinish: { destination = .home }))
            }
        }
        .momogoTopToast($toast)
    }
}
