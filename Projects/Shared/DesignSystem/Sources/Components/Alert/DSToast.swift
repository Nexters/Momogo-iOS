import SwiftUI

public struct DSToast: View {
    public enum Tone {
        case notice
        case error
        case success
    }

    private let message: String
    private let tone: Tone

    public init(_ message: String, tone: Tone = .notice) {
        self.message = message
        self.tone = tone
    }

    public var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(indicatorColor)
                .frame(width: 8, height: 8)
            Text(message)
                .momogoTypography(.smMedium)
                .foregroundStyle(DesignSystem.Color.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(DesignSystem.Color.gray800)
        .clipShape(Capsule())
        .momogoShadow()
    }

    private var indicatorColor: Color {
        switch tone {
        case .notice: return DesignSystem.Color.primary500
        case .error: return DesignSystem.Color.systemRed500
        case .success: return DesignSystem.Color.systemGreen500
        }
    }
}

extension View {
    /// Figma 스펙: Toast는 3초 후 자동으로 사라짐
    public func momogoToast(isPresented: Binding<Bool>, message: String, tone: DSToast.Tone = .notice) -> some View {
        overlay(alignment: .bottom) {
            if isPresented.wrappedValue {
                DSToast(message, tone: tone)
                    .padding(.bottom, 32)
                    .transition(.opacity)
                    .task {
                        try? await Task.sleep(for: .seconds(3))
                        isPresented.wrappedValue = false
                    }
            }
        }
    }
}
