import SwiftUI

import Dependencies
import DomainInterface
import FeatureReaction

@main
struct ReactionExampleApp: App {
    private enum Constants {
        static let groupId = 10
        static let groupName = "성민아 밥먹자"
        static let dateText = "8월 5일 (수)"
        /// 진입 카드는 '반응_기본'(친구 점심 + 리액션 있음) 상태인 길동으로 맞춘다.
        static let selectedUserId = 2
        static let reportPlaceholderSuffix = " 신고 화면은 FeatureHome이 제공합니다"
    }

    init() {
        prepareDependencies {
            $0.deletePhotoUseCase = .happyPath
            // 이 데모 앱은 Data/Domain 모듈을 링크하지 않아 liveValue가 없다. override하지 않으면
            // 이모지 탭마다 unimplemented testValue가 호출된다. 빈 배열을 반환해 항상 폴백 문구를 쓰게 한다.
            $0.getCommentsUseCase = GetCommentsUseCase(execute: { _, _ in [] })
            $0.addReactionUseCase = .happyPath
            $0.getReactionsUseCase = GetReactionsUseCase(execute: { _, _ in [] })
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ReactionView(
                    viewModel: ReactionViewModel(
                        groupId: Constants.groupId,
                        groupName: Constants.groupName,
                        dateText: Constants.dateText,
                        members: GroupMember.reactionMocks,
                        selectedUserId: Constants.selectedUserId
                    ),
                    reportDestination: { target in
                        // 신고 화면은 FeatureHome이 소유해 이 Example에서는 대체 화면만 보여준다.
                        // 실제 신고 플로우는 FeatureHomeExample(그룹상세 → 사진 탭 → 미트볼)에서 확인한다.
                        Text(target.nickname + Constants.reportPlaceholderSuffix)
                    }
                )
            }
        }
    }
}
