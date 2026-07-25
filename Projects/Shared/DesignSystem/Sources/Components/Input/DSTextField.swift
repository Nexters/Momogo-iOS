import SwiftUI

public struct DSTextField: View {
    public enum State {
        case normal
        case focused
        case error
    }

    @Environment(\.isEnabled) private var isEnabled
    @Binding private var text: String
    private let placeholder: String
    private let comment: String?
    private let characterLimit: Int?
    private let state: State

    public init(
        _ placeholder: String,
        text: Binding<String>,
        comment: String? = nil,
        characterLimit: Int? = nil,
        state: State = .normal
    ) {
        self.placeholder = placeholder
        _text = text
        self.comment = comment
        self.characterLimit = characterLimit
        self.state = state
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                TextField(placeholder, text: $text)
                    .momogoTypography(.mdMedium)
                    .foregroundStyle(DesignSystem.Color.white)
                if let characterLimit {
                    Text("\(text.count)/\(characterLimit)")
                        .momogoTypography(.xsMedium)
                        .foregroundStyle(DesignSystem.Color.gray400)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.r12)
                    .stroke(borderColor, lineWidth: 1)
            )

            if let comment {
                Text(comment)
                    .momogoTypography(.xsMedium)
                    .foregroundStyle(commentColor)
            }
        }
        .opacity(isEnabled ? 1 : 0.4)
    }

    private var borderColor: Color {
        switch state {
        case .normal: DesignSystem.Color.gray600
        case .focused: DesignSystem.Color.primary500
        case .error: DesignSystem.Color.systemRed500
        }
    }

    private var commentColor: Color {
        state == .error ? DesignSystem.Color.systemRed500 : DesignSystem.Color.gray400
    }
}
