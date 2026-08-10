import Foundation

import DesignSystem
import DomainInterface

/// 그룹 참여 플로우 전용 문구를 DS의 `DSTopToastContent`로 매핑한다.
/// 도메인 지식(`GroupJoinError`)은 여기 Feature 쪽에 두고, DesignSystem은 순수 표시 컴포넌트만 제공한다.
extension DSTopToastContent {
    /// 서버 에러 사유에 알맞은 문구를 매핑한다.
    init(_ error: GroupJoinError) {
        switch error {
        case .invalidInvitationCode:
            self.init(message: "초대코드가 유효하지 않아요", tone: .error)
        case .groupFull:
            self.init(message: "그룹이 꽉 차서 참여할 수 없어요", tone: .notice)
        case .alreadyJoined:
            self.init(message: "이미 참여 중인 그룹이에요", tone: .notice)
        }
    }

    private static let fallbackMessage = "잠시 후 다시 시도해주세요."

    // 접근할 때마다 새 인스턴스(=새 id)를 만들어야 `.task(id:)` 타이머가 매번 재시작된다.
    static var fallback: DSTopToastContent { DSTopToastContent(message: fallbackMessage, tone: .error) }

    /// 그룹 참여를 완료하고 JoinConfirm 화면에 도착했을 때 뜨는 토스트.
    static var joinCompleted: DSTopToastContent { DSTopToastContent(message: "그룹에 합류했어요!", tone: .success) }

    /// 초대코드를 클립보드에 복사했을 때 뜨는 토스트. 복사 자체는 실패하지 않는 동작이라 항상 success 톤이다.
    static var copiedToClipboard: DSTopToastContent { DSTopToastContent(message: "클립보드에 복사되었어요", tone: .success) }
}
