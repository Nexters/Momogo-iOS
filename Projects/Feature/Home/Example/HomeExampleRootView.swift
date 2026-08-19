import SwiftUI

import Dependencies
import DomainInterface
import FeatureHome

/// New 배지 시나리오를 시연하는 Example 전용 루트. 카드를 탭하면 실제 그룹 상세 화면으로 push되며,
/// 그 과정에서 방문 기록 → 배지 소멸까지 전체 흐름을 확인할 수 있다.
struct HomeExampleRootView: View {
    @State private var scenario: Scenario = .newBadge
    @State private var showHome = false

    /// "우리 가족"(groupId 10)만 활성 사진이 있어 New 배지 후보다. `.allSeen`은 그 값을 방문 기록에
    /// 미리 심어 둬 배지가 애초에 뜨지 않는 상태를 재현한다.
    enum Scenario: String, CaseIterable, Identifiable {
        case newBadge = "New 배지 있음"
        case allSeen = "이미 다 본 상태"
        case empty = "그룹 없음"
        case failed = "조회 실패"

        var id: String { rawValue }

        var getGroupsUseCase: GetGroupsUseCase {
            switch self {
            case .newBadge, .allSeen: .happyPath
            case .empty: .emptyPath
            case .failed: .failedPath
            }
        }

        var visitSeed: [Int: String] {
            switch self {
            case .newBadge, .empty, .failed: [:]
            case .allSeen: [10: GetGroupsUseCase.recentUploadAt]
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Picker("시나리오", selection: $scenario) {
                    ForEach(Scenario.allCases) { scenario in
                        Text(scenario.rawValue).tag(scenario)
                    }
                }

                Button("홈 화면 보기") {
                    showHome = true
                }
            }
            .padding()
            .navigationDestination(isPresented: $showHome) {
                homeView(for: scenario)
            }
        }
    }

    private func homeView(for scenario: Scenario) -> some View {
        // 시나리오를 바꿔 다시 들어와도 이전 탭 상태가 새지 않도록, 진입할 때마다 새 저장소를 만든다.
        let visitStore = GroupVisitMockStore(seed: scenario.visitSeed)

        return withDependencies {
            $0.getGroupsUseCase = scenario.getGroupsUseCase
            $0.getGroupVisitsUseCase = visitStore.getUseCase
            $0.markGroupVisitedUseCase = visitStore.markUseCase
            $0.getMyPhotosUseCase = .happyPath
            // 그룹 생성·참여 플로우도 함께 주입해야 홈의 플러스 메뉴 이후 화면까지 확인할 수 있다.
            $0.createGroupUseCase = .happyPath
            $0.checkGroupByCodeUseCase = .happyPath
            $0.joinGroupByCodeUseCase = .happyPath
            // 카드 탭으로 들어가는 실제 그룹 상세 화면(조회/이름 변경/나가기/사진 신고·삭제)도 함께 주입해야 push 이후가 동작한다.
            $0.getGroupDetailUseCase = .happyPath
            $0.updateGroupNameUseCase = .happyPath
            $0.leaveGroupUseCase = .happyPath
            $0.reportPhotoUseCase = .happyPath
            $0.deletePhotoUseCase = .happyPath
            $0.getPhotoReactionsUseCase = .happyPath
        } operation: {
            HomeView(viewModel: HomeViewModel())
        }
    }
}
