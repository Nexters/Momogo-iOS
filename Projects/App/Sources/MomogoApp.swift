import SwiftUI

import FeatureHome
import FeatureOnboarding
import FirebaseCore

@main
struct MomogoApp: App {
    // 지금은 온보딩 완료 시 바로 HomeView로 넘어가는 임시 분기다.
    // 추후 Splash에서 세션 확인 결과에 따라 온보딩/홈으로 라우팅하도록 대체할 예정.
    @State private var didFinishOnboarding = false

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if didFinishOnboarding {
                HomeView(viewModel: HomeViewModel())
            } else {
                OnboardingView(viewModel: OnboardingViewModel(onFinish: { didFinishOnboarding = true }))
            }
        }
    }
}
