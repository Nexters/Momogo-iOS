import SwiftUI

import Dependencies
import DomainInterface
import FeatureHome

@main
struct HomeExampleApp: App {
    init() {
        prepareDependencies {
            $0.getGroupsUseCase = .happyPath
            // 그룹 생성·참여 플로우는 FeatureGroup 화면이 담당하므로 해당 UseCase도 함께 주입해야 push 이후가 동작한다.
            // 다만 getGroupsUseCase가 고정 목록을 돌려주므로, 생성 후 목록이 늘어나는 것까지는 실제 앱에서 확인해야 한다.
            $0.createGroupUseCase = .happyPath
            $0.checkGroupByCodeUseCase = .happyPath
            $0.joinGroupByCodeUseCase = .happyPath
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel())
        }
    }
}
