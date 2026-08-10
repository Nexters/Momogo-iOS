import Foundation
import UIKit

import Dependencies
import DomainInterface

@Observable
@MainActor
public final class SplashViewModel {
    private enum Constants {
        static let minimumExposureDuration: Duration = .seconds(2)
        static let sessionCheckTimeout: Duration = .seconds(5)
        static let versionCheckTimeout: Duration = .seconds(5)
    }

    @ObservationIgnored
    @Dependency(\.checkSessionUseCase) private var checkSessionUseCase
    @ObservationIgnored
    @Dependency(\.checkAppVersionUseCase) private var checkAppVersionUseCase

    /// non-nil이면 강제 업데이트 모달을 띄우고 onFinish를 호출하지 않아 앱 진입이 차단된다.
    private(set) var forceUpdateStoreURL: URL?

    private let onFinish: (SplashDestination) -> Void

    public init(onFinish: @escaping (SplashDestination) -> Void) {
        self.onFinish = onFinish
    }

    /// 세션 체크가 아무리 빨리 끝나도 스플래시는 최소 2초간 노출하며, 세션 체크·버전 체크는 각각 최대 5초까지만 기다린다.
    /// 강제 업데이트가 필요하면 세션 체크 결과와 무관하게 진입을 차단한다.
    func start() async {
        let checkSessionUseCase = checkSessionUseCase
        let checkAppVersionUseCase = checkAppVersionUseCase

        async let storeURL = Self.resolveForceUpdate(checkAppVersionUseCase: checkAppVersionUseCase)
        async let destination = Self.resolveDestination(checkSessionUseCase: checkSessionUseCase)
        try? await Task.sleep(for: Constants.minimumExposureDuration)

        let (url, next) = await (storeURL, destination)

        if let url {
            forceUpdateStoreURL = url
            return
        }
        onFinish(next)
    }

    /// 강제 업데이트 모달의 "확인" 버튼 액션. 스토어로 이동한 뒤에도 모달은 닫히지 않아 진입 차단이 유지된다.
    func updateConfirmTapped() {
        guard let forceUpdateStoreURL else { return }
        UIApplication.shared.open(forceUpdateStoreURL)
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

    /// 강제 업데이트가 필요하고 이동할 스토어 URL이 유효할 때만 그 URL을 반환한다.
    /// 체크 실패·타임아웃은 물론, forceUpdate가 true여도 URL이 유효하지 않으면 nil을 반환해 앱을 차단하지 않는다.
    /// (닫기 버튼이 없는 모달 + 동작하지 않는 버튼 조합은 사용자에게 탈출구가 없기 때문)
    private static func resolveForceUpdate(checkAppVersionUseCase: CheckAppVersionUseCase) async -> URL? {
        await withTaskGroup(of: URL?.self) { group in
            group.addTask {
                guard
                    let result = try? await checkAppVersionUseCase.execute(),
                    result.isForceUpdateRequired
                else { return nil }
                return result.updateURL
            }
            group.addTask {
                try? await Task.sleep(for: Constants.versionCheckTimeout)
                return nil
            }
            // group.next()는 URL??을 반환한다(그룹이 비면 outer nil). flatMap으로 URL?로 평탄화한다.
            let url = await group.next().flatMap { $0 }
            group.cancelAll()
            return url
        }
    }
}
