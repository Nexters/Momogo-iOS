import SwiftUI

import Dependencies
import DomainInterface
import FeatureSplash

struct SplashExampleRootView: View {
    private enum Scenario {
        case validSession
        case noSession

        var destination: SplashDestination {
            switch self {
            case .validSession: .home
            case .noSession: .onboarding
            }
        }
    }

    @State private var scenario: Scenario?
    @State private var result: SplashDestination?

    var body: some View {
        if let result {
            resultView(result)
        } else if let scenario {
            splashView(for: scenario)
        } else {
            pickerView
        }
    }

    private var pickerView: some View {
        VStack(spacing: 12) {
            Text("스플래시가 시뮬레이션할 상황을 선택하세요")

            Button("세션 있음 → Home") {
                scenario = .validSession
            }
            Button("세션 없음 → Onboarding") {
                scenario = .noSession
            }
        }
        .padding()
    }

    /// 실제 백엔드 연동 전까지, 데모 앱에서는 checkSessionUseCase를 Mock으로 override해서 각 시나리오의 라우팅 결과를 확인한다.
    private func splashView(for scenario: Scenario) -> some View {
        withDependencies {
            $0.checkSessionUseCase = CheckSessionUseCase(
                execute: {
                    try? await Task.sleep(for: .seconds(1))
                    return scenario.destination
                }
            )
        } operation: {
            SplashView(viewModel: SplashViewModel(onFinish: { result = $0 }))
        }
    }

    private func resultView(_ destination: SplashDestination) -> some View {
        VStack(spacing: 12) {
            Text("이동: \(String(describing: destination))")

            Button("다시 보기") {
                result = nil
                scenario = nil
            }
        }
        .padding()
    }
}
