import Foundation

import Dependencies
import DomainInterface

@Observable
@MainActor
public final class SplashViewModel {
    private enum Constants {
        static let minimumExposureDuration: Duration = .seconds(2)
        static let sessionCheckTimeout: Duration = .seconds(5)
    }

    @ObservationIgnored
    @Dependency(\.checkSessionUseCase) private var checkSessionUseCase

    private let onFinish: (SplashDestination) -> Void

    public init(onFinish: @escaping (SplashDestination) -> Void) {
        self.onFinish = onFinish
    }

    /// 세션 체크가 아무리 빨리 끝나도 스플래시는 최소 2초간 노출하며, 세션 체크는 최대 5초까지만 기다린다.
    func start() async {
        let checkSessionUseCase = checkSessionUseCase
        async let destination = Self.resolveDestination(checkSessionUseCase: checkSessionUseCase)
        try? await Task.sleep(for: Constants.minimumExposureDuration)
        onFinish(await destination)
    }

    private static func resolveDestination(checkSessionUseCase: CheckSessionUseCase) async -> SplashDestination {
        await withTaskGroup(of: SplashDestination.self) { group in
            group.addTask { await checkSessionUseCase.execute() }
            group.addTask {
                try? await Task.sleep(for: Constants.sessionCheckTimeout)
                return .onboarding
            }
            let destination = await group.next() ?? .onboarding
            group.cancelAll()
            return destination
        }
    }
}
