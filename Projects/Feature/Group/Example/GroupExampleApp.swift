import SwiftUI

import Dependencies
import DomainInterface

@main
struct GroupExampleApp: App {
    init() {
        prepareDependencies {
            $0.createGroupUseCase = .happyPath
        }
    }

    var body: some Scene {
        WindowGroup {
            GroupExampleRootView()
        }
    }
}
