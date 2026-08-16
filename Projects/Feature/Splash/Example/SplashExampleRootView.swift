import Foundation
import SwiftUI

import Dependencies
import DomainInterface
import FeatureSplash

struct SplashExampleRootView: View {
    private enum Scenario: CaseIterable, Hashable {
        case validSession
        case noSession
        case forceUpdateBlocked
        case forceUpdateInvalidURL
        case forceUpdateCheckFailed

        var title: String {
            switch self {
            case .validSession: "세션 있음 → Home"
            case .noSession: "세션 없음 → Onboarding"
            case .forceUpdateBlocked: "강제 업데이트(유효 URL) → 차단"
            case .forceUpdateInvalidURL: "강제 업데이트(updateUrl 없음) → 통과"
            case .forceUpdateCheckFailed: "버전 체크 실패 → 통과(fail-open)"
            }
        }

        /// 강제 업데이트로 차단되지 않는 시나리오에서 세션 체크가 도달할 목적지.
        var sessionDestination: SplashDestination {
            switch self {
            case .validSession, .forceUpdateInvalidURL, .forceUpdateCheckFailed: .home
            case .noSession, .forceUpdateBlocked: .onboarding
            }
        }

        func checkAppVersion() async throws -> AppVersionCheckResult {
            try? await Task.sleep(for: .seconds(1))
            switch self {
            case .validSession, .noSession:
                return AppVersionCheckResult(isForceUpdateRequired: false, updateURL: nil)
            case .forceUpdateBlocked:
                return AppVersionCheckResult(
                    isForceUpdateRequired: true,
                    updateURL: URL(string: "https://apps.apple.com/app/id000000000")
                )
            case .forceUpdateInvalidURL:
                // 서버가 forceUpdate: true를 내려도 updateUrl이 비어 있으면 앱을 차단하지 않는다 (탈출구 없는 모달 방지).
                return AppVersionCheckResult(isForceUpdateRequired: true, updateURL: nil)
            case .forceUpdateCheckFailed:
                throw URLError(.notConnectedToInternet)
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

            ForEach(Scenario.allCases, id: \.self) { scenario in
                Button(scenario.title) {
                    self.scenario = scenario
                }
            }
        }
        .padding()
    }

    /// 실제 백엔드 연동 전까지, 데모 앱에서는 checkSessionUseCase/checkAppVersionUseCase를 Mock으로 override해서
    /// 각 시나리오(세션 라우팅 + 강제 업데이트 차단/통과)의 결과를 확인한다.
    private func splashView(for scenario: Scenario) -> some View {
        withDependencies {
            $0.checkSessionUseCase = CheckSessionUseCase(
                execute: {
                    try? await Task.sleep(for: .seconds(1))
                    return scenario.sessionDestination
                }
            )
            $0.checkAppVersionUseCase = CheckAppVersionUseCase(
                execute: { try await scenario.checkAppVersion() }
            )
        } operation: {
            // 강제 업데이트로 차단되는 시나리오는 onFinish가 호출되지 않아 이 화면에 머문다.
            // "다시 선택"은 실제 앱에는 없는, 데모 전용 탈출구다.
            ZStack(alignment: .bottom) {
                SplashView(viewModel: SplashViewModel(onFinish: { result = $0 }))
                Button("다시 선택") { self.scenario = nil }
                    .padding()
            }
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
