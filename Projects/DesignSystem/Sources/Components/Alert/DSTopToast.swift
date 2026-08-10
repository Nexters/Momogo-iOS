import SwiftUI

/// 화면 상단에 표시되는 토스트. 하단에 표시되는 `DSToast`와는 위치·모양·톤 색상이 달라 별도 컴포넌트로 둔다.
public struct DSTopToast: View {
    public enum Tone: Sendable {
        case error
        case notice
        case success
    }

    private let message: String
    private let tone: Tone

    public init(_ message: String, tone: Tone) {
        self.message = message
        self.tone = tone
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(asset: icon)
                .renderingMode(.template)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(iconColor)
                .accessibilityHidden(true)
            Text(message)
                .momogoTypography(.mdSemistrong)
                .foregroundStyle(DesignSystem.Color.gray50)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(DesignSystem.Color.gray900.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r16))
        .overlay {
            RoundedRectangle(cornerRadius: DesignSystem.Radius.r16)
                .strokeBorder(.white.opacity(0.04), lineWidth: 1.5)
        }
        .momogoShadow()
    }

    private var icon: DesignSystemImages {
        switch tone {
        case .error, .notice: DesignSystemAsset.infoFill
        case .success: DesignSystemAsset.checkCheck
        }
    }

    private var iconColor: Color {
        switch tone {
        case .error: DesignSystem.Color.systemRed500
        case .notice: DesignSystem.Color.systemBlue500
        case .success: DesignSystem.Color.systemGreen500
        }
    }
}
