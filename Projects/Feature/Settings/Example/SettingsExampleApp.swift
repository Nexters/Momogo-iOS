import SwiftUI

import Dependencies
import DomainInterface
import FeatureSettings

@main
struct SettingsExampleApp: App {
    init() {
        prepareDependencies {
            $0.updateNicknameUseCase = .happyPath
            $0.deleteAccountUseCase = .happyPath
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SettingsView(viewModel: SettingsViewModel())
            }
        }
    }
}
