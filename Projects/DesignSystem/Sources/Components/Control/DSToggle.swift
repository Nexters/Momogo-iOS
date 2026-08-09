import SwiftUI

public struct DSToggle: View {
    @Environment(\.isEnabled) private var isEnabled
    @Binding private var isOn: Bool
    private let title: String?

    public init(_ title: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        _isOn = isOn
    }

    public var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: 8) {
                if let title {
                    Text(title)
                        .momogoTypography(.smMedium)
                        .foregroundStyle(DesignSystem.Color.gray50)
                }
                track
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }

    private var track: some View {
        RoundedRectangle(cornerRadius: DesignSystem.Radius.full)
            .fill(isOn ? DesignSystem.Color.primary500 : DesignSystem.Color.gray700)
            .frame(width: 50, height: 28)
            .overlay(alignment: isOn ? .trailing : .leading) {
                Circle()
                    .fill(isOn ? DesignSystem.Color.gray900 : DesignSystem.Color.gray50)
                    .frame(width: 20, height: 20)
                    .padding(4)
            }
            .animation(.easeInOut(duration: 0.15), value: isOn)
    }
}
