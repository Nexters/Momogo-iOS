import SwiftUI

public struct DSTextField: View {
    public enum State {
        case normal
        case filled
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
            HStack(spacing: 8) {
                TextField(placeholder, text: $text)
                    .momogoTypography(.mdMedium)
                    .foregroundStyle(textColor)
                if let characterLimit {
                    Text("\(text.count)/\(characterLimit)")
                        .momogoTypography(.mdMedium)
                        .foregroundStyle(countColor)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(DesignSystem.Color.gray900)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(borderColor, lineWidth: borderWidth)
            )

            if let comment {
                Text(comment)
                    .momogoTypography(.xsMedium)
                    .foregroundStyle(commentColor)
                    .padding(.leading, 12)
            }
        }
    }

    private var borderColor: Color {
        guard isEnabled else { return .clear }
        return switch state {
        case .error: DesignSystem.Color.systemRed500
        case .focused: DesignSystem.Color.primary500
        case .normal, .filled: DesignSystem.Color.gray800
        }
    }

    private var borderWidth: CGFloat {
        guard isEnabled else { return 0 }
        return switch state {
        case .error, .focused: 1.5
        case .normal, .filled: 1
        }
    }

    private var textColor: Color {
        guard isEnabled else { return DesignSystem.Color.gray600 }
        return switch state {
        case .normal: DesignSystem.Color.gray400
        case .filled, .focused, .error: DesignSystem.Color.gray50
        }
    }

    private var countColor: Color {
        guard isEnabled else { return DesignSystem.Color.gray600 }
        return switch state {
        case .normal, .filled: DesignSystem.Color.gray400
        case .focused: DesignSystem.Color.gray50
        case .error: DesignSystem.Color.systemRed500
        }
    }

    private var commentColor: Color {
        state == .error ? DesignSystem.Color.systemRed500 : DesignSystem.Color.gray200
    }
}
