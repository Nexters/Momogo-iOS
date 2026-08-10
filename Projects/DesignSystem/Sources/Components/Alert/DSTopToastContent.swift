import Foundation

/// `DSTopToast`에 표시할 내용. 매번 새 `id`를 발급해, 같은 문구를 연속으로 띄워도
/// 자동 해제 타이머(`momogoTopToast(_:)`)가 재시작되도록 한다.
public struct DSTopToastContent: Identifiable, Equatable, Sendable {
    public let id = UUID()
    public let message: String
    public let tone: DSTopToast.Tone

    public init(message: String, tone: DSTopToast.Tone) {
        self.message = message
        self.tone = tone
    }
}
