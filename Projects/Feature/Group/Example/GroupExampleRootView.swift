import SwiftUI

import Dependencies
import DomainInterface
import FeatureGroup

struct GroupExampleRootView: View {
    @State private var showCreate = false
    @State private var showJoin = false
    @State private var joinScenario: JoinScenario = .happyPath

    /// 그룹 참여 토스트를 시나리오별로 눈으로 확인하기 위한 Example 전용 선택지.
    enum JoinScenario: String, CaseIterable, Identifiable {
        case happyPath = "성공"
        case invalidCode = "유효하지 않은 코드 (404)"
        case groupFull = "그룹 정원 초과 (409)"
        case alreadyJoined = "이미 참여한 그룹 (409)"
        case unknownFailure = "알 수 없는 실패"

        var id: String { rawValue }

        var checkUseCase: CheckGroupByCodeUseCase {
            switch self {
            case .happyPath, .groupFull, .alreadyJoined: .happyPath
            case .invalidCode: .invalidCodePath
            case .unknownFailure: .failedPath
            }
        }

        var joinUseCase: JoinGroupByCodeUseCase {
            switch self {
            case .happyPath, .invalidCode: .happyPath
            case .groupFull: .groupFullPath
            case .alreadyJoined: .alreadyJoinedPath
            case .unknownFailure: .failedPath
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Button("그룹 만들기") {
                    showCreate = true
                }

                Picker("참여 시나리오", selection: $joinScenario) {
                    ForEach(JoinScenario.allCases) { scenario in
                        Text(scenario.rawValue).tag(scenario)
                    }
                }

                Button("초대코드로 참여하기") {
                    showJoin = true
                }
            }
            .navigationDestination(isPresented: $showCreate) {
                GroupNameView(viewModel: GroupNameViewModel(onFinish: {}))
            }
            .navigationDestination(isPresented: $showJoin) {
                withDependencies {
                    $0.checkGroupByCodeUseCase = joinScenario.checkUseCase
                    $0.joinGroupByCodeUseCase = joinScenario.joinUseCase
                } operation: {
                    InviteCodeInputView(viewModel: InviteCodeInputViewModel(onFinish: {}))
                }
            }
        }
    }
}
