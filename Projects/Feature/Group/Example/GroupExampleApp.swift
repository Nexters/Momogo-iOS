import SwiftUI

import Dependencies
import DomainInterface

@main
struct GroupExampleApp: App {
    init() {
        prepareDependencies {
            $0.groupClient = .happyPath
        }
    }

    var body: some Scene {
        WindowGroup {
            GroupExampleRootView()
        }
    }
}
