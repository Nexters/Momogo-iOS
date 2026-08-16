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
                // 없으면 NavigationStack의 시스템 기본(라이트) 배경이 전환 중 번쩍인다.
                .preferredColorScheme(.dark)
        }
    }
}

private struct RootView: View {
    private enum RootDestination {
        case splash
        case home
        case onboarding
    }

    private static let transitionAnimation: Animation = .easeInOut(duration: 0.4)

    @State private var destination: RootDestination = .splash
    /// 온보딩에서 그룹까지 만들고 끝난 경우, 홈이 그 그룹의 상세로 바로 진입할 수 있도록 잠시 들고 있는다.
    @State private var pendingCreatedGroup: CreateGroupResponse?

    var body: some View {
        Group {
            switch destination {
            case .splash:
                SplashView(viewModel: SplashViewModel(onFinish: { splashDestination in
                    withAnimation(Self.transitionAnimation) {
                        switch splashDestination {
                        case .home:
                            destination = .home
                        case .onboarding:
                            destination = .onboarding
                        }
                    }
                }))
                .transition(.opacity)
            case .home:
                HomeView(viewModel: HomeViewModel(
                    initialCreatedGroup: pendingCreatedGroup,
                    onLogout: { withAnimation(Self.transitionAnimation) { destination = .onboarding } }
                ))
                .transition(.opacity)
            case .onboarding:
                OnboardingView(viewModel: OnboardingViewModel(onFinish: { createdGroup in
                    withAnimation(Self.transitionAnimation) {
                        pendingCreatedGroup = createdGroup
                        destination = .home
                    }
                }))
                .transition(.opacity)
            }
        }
        // 각 화면 배경도 트랜지션에 fade되어 윈도우 기본색이 비치므로, 무관한 고정 배경을 따로 깐다.
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
    }
}
