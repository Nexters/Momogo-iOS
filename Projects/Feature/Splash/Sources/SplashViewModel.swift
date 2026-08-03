import Foundation

import Dependencies
import DomainInterface

@Observable
@MainActor
public final class SplashViewModel {
    @ObservationIgnored
    @Dependency(\.checkSessionUseCase) private var checkSessionUseCase

    private let onFinish: (SplashDestination) -> Void

    public init(onFinish: @escaping (SplashDestination) -> Void) {
        self.onFinish = onFinish
    }

    func start() async {
        let destination = await checkSessionUseCase.execute()
        onFinish(destination)
    }
}
