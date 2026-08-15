import SwiftUI

@main
struct HomeExampleApp: App {
    // 시나리오별 의존성 주입은 HomeExampleRootView가 진입 시점마다 새로 구성한다
    // (New 배지 데모는 시나리오마다 독립된 방문 기록 mock이 필요해 앱 시작 시점의 고정 주입으로는 부족하다).
    var body: some Scene {
        WindowGroup {
            HomeExampleRootView()
        }
    }
}
