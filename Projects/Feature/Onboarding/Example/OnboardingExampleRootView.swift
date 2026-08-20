import SwiftUI

import Dependencies
import DomainInterface
import FeatureOnboarding

struct OnboardingExampleRootView: View {
    @State private var showNickname = false
    @State private var signUpScenario: SignUpScenario = .happyPath

    /// 회원가입 성공/실패 Toast를 눈으로 확인하기 위한 Example 전용 선택지.
    enum SignUpScenario: String, CaseIterable, Identifiable {
        case happyPath = "성공"
        case failedPath = "실패"

        var id: String { rawValue }

        var signUpUseCase: SignUpUseCase {
            switch self {
            case .happyPath: .happyPath
            case .failedPath: .failedPath
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Picker("회원가입 시나리오", selection: $signUpScenario) {
                    ForEach(SignUpScenario.allCases) { scenario in
                        Text(scenario.rawValue).tag(scenario)
                    }
                }

                Button("닉네임 입력 화면부터 시작") {
                    showNickname = true
                }
            }
            .padding()
            .navigationDestination(isPresented: $showNickname) {
                withDependencies {
                    $0.signUpUseCase = signUpScenario.signUpUseCase
                } operation: {
                    NicknameView(viewModel: NicknameViewModel(onFinish: { _ in }))
                }
            }
        }
    }
}
