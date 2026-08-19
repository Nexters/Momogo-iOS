import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import FeatureSplash

@MainActor
struct FeatureSplashTests {
    @Test("forceUpdate가 false면 세션 체크 결과대로 onFinish가 호출되고 모달은 뜨지 않는다")
    func start_noForceUpdate_finishesWithSessionDestination() async throws {
        var finished: SplashDestination?

        let viewModel = withDependencies {
            $0.checkAppVersionUseCase = CheckAppVersionUseCase(
                execute: { AppVersionCheckResult(isForceUpdateRequired: false, updateURL: nil) }
            )
            $0.checkSessionUseCase = CheckSessionUseCase(execute: { .home })
            $0.syncCommentsUseCase = SyncCommentsUseCase(execute: {})
        } operation: {
            SplashViewModel(onFinish: { finished = $0 })
        }

        await viewModel.start()

        #expect(finished == .home)
        #expect(viewModel.forceUpdateStoreURL == nil)
    }

    @Test("forceUpdate가 true이고 updateURL이 유효하면 onFinish를 호출하지 않고 진입을 차단한다")
    func start_forceUpdateWithValidURL_blocksEntry() async throws {
        var finished: SplashDestination?
        let storeURL = URL(string: "https://apps.apple.com/app/id000000000")

        let viewModel = withDependencies {
            $0.checkAppVersionUseCase = CheckAppVersionUseCase(
                execute: { AppVersionCheckResult(isForceUpdateRequired: true, updateURL: storeURL) }
            )
            $0.checkSessionUseCase = CheckSessionUseCase(execute: { .home })
            $0.syncCommentsUseCase = SyncCommentsUseCase(execute: {})
        } operation: {
            SplashViewModel(onFinish: { finished = $0 })
        }

        await viewModel.start()

        #expect(finished == nil)
        #expect(viewModel.forceUpdateStoreURL == storeURL)
    }

    @Test("forceUpdate가 true여도 updateURL이 없으면 차단하지 않고 통과시킨다")
    func start_forceUpdateWithoutURL_doesNotBlock() async throws {
        var finished: SplashDestination?

        let viewModel = withDependencies {
            $0.checkAppVersionUseCase = CheckAppVersionUseCase(
                execute: { AppVersionCheckResult(isForceUpdateRequired: true, updateURL: nil) }
            )
            $0.checkSessionUseCase = CheckSessionUseCase(execute: { .onboarding })
            $0.syncCommentsUseCase = SyncCommentsUseCase(execute: {})
        } operation: {
            SplashViewModel(onFinish: { finished = $0 })
        }

        await viewModel.start()

        #expect(finished == .onboarding)
        #expect(viewModel.forceUpdateStoreURL == nil)
    }

    @Test("버전 체크가 실패하면 차단하지 않고 통과시킨다 (fail-open)")
    func start_versionCheckThrows_doesNotBlock() async throws {
        var finished: SplashDestination?

        let viewModel = withDependencies {
            $0.checkAppVersionUseCase = CheckAppVersionUseCase(
                execute: { throw SplashTestError.networkFailed }
            )
            $0.checkSessionUseCase = CheckSessionUseCase(execute: { .home })
            $0.syncCommentsUseCase = SyncCommentsUseCase(execute: {})
        } operation: {
            SplashViewModel(onFinish: { finished = $0 })
        }

        await viewModel.start()

        #expect(finished == .home)
        #expect(viewModel.forceUpdateStoreURL == nil)
    }
}

private enum SplashTestError: Error {
    case networkFailed
}
