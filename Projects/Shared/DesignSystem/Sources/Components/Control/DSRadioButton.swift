import SwiftUI

public struct DSRadioButton: View {
    @Environment(\.isEnabled) private var isEnabled
    @Binding private var isSelected: Bool
    private let title: String

    public init(_ title: String, isSelected: Binding<Bool>) {
        self.title = title
        _isSelected = isSelected
    }

    public var body: some View {
        Button {
            isSelected = true
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .strokeBorder(DesignSystem.Color.white, lineWidth: 1.5)
                    .background(
                        Circle()
                            .fill(isSelected ? DesignSystem.Color.white : .clear)
                            .padding(4)
                    )
                    .frame(width: 20, height: 20)
                Text(title)
                    .momogoTypography(.mdMedium)
                    .foregroundStyle(DesignSystem.Color.gray50)
            }
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.4)
    }
}
