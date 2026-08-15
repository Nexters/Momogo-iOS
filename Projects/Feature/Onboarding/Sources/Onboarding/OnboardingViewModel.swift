import Foundation

import Dependencies
import DomainInterface
import SwiftUINavigation

@Observable
@MainActor
public final class OnboardingViewModel {
    var destination: Destination?
    var isLoading: Bool = false

    @ObservationIgnored
    @Dependency(\.loginUseCase) private var loginUseCase

    /// 그룹 생성까지 마치고 온보딩이 끝난 경우, 홈이 그 그룹의 상세로 바로 진입할 수 있도록 생성 결과를 함께 전달한다.
    /// 기존 유저 로그인·그룹 참여로 끝난 경우에는 nil을 전달해 기존처럼 홈으로만 이동한다.
    private let onFinish: (CreateGroupResponse?) -> Void

    public init(onFinish: @escaping (CreateGroupResponse?) -> Void = { _ in }) {
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case nickname(NicknameViewModel)
    }

    func guestStartTapped() {
        guard !isLoading else { return }

        isLoading = true

        Task {
            defer { isLoading = false }

            if await loginUseCase.execute() {
                onFinish(nil)
            } else {
                destination = .nickname(NicknameViewModel(onFinish: onFinish))
            }
        }
    }
}
