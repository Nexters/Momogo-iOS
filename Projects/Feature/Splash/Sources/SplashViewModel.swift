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

    /// 세션 체크가 아무리 빨리 끝나도 스플래시는 최소 2초간 노출한다.
    func start() async {
        async let destination = checkSessionUseCase.execute()
        try? await Task.sleep(for: .seconds(2))
        onFinish(await destination)
    }
}
