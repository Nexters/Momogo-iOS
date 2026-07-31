import SwiftUI

import Dependencies
import DomainInterface
import FeatureHome

@main
struct HomeExampleApp: App {
    init() {
        prepareDependencies {
            $0.getGroupsUseCase = .happyPath
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel())
        }
    }
}
