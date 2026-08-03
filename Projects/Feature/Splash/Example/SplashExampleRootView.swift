import SwiftUI

import Dependencies
import DomainInterface
import FeatureSplash

struct SplashExampleRootView: View {
    @State private var destination: SplashDestination?

    var body: some View {
        if let destination {
            Text("이동: \(String(describing: destination))")
        } else {
            splashView
        }
    }

    /// 실제 백엔드 연동 전까지, 데모 앱에서는 checkSessionUseCase를 Mock으로 override해서 라우팅 결과를 확인한다.
    private var splashView: some View {
        withDependencies {
            $0.checkSessionUseCase = CheckSessionUseCase(
                execute: {
                    try? await Task.sleep(for: .seconds(1))
                    return .home
                }
            )
        } operation: {
            SplashView(viewModel: SplashViewModel(onFinish: { destination = $0 }))
        }
    }
}
