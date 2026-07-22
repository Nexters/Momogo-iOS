import SwiftUI

public struct DSTopNavigationBar<Leading: View, Trailing: View>: View {
    public enum TitleAlignment {
        case leading
        case center
    }

    private let title: String?
    private let alignment: TitleAlignment
    private let leading: Leading
    private let trailing: Trailing

    public init(
        title: String? = nil,
        alignment: TitleAlignment = .center,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.alignment = alignment
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
        ZStack {
            if alignment == .center, let title {
                Text(title)
                    .momogoTypography(.lgSemistrong)
                    .foregroundStyle(DesignSystem.Color.white)
            }
            HStack {
                leading
                if alignment == .leading, let title {
                    Text(title)
                        .momogoTypography(.lgSemistrong)
                        .foregroundStyle(DesignSystem.Color.white)
                }
                Spacer()
                trailing
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
    }
}

extension DSTopNavigationBar where Leading == EmptyView, Trailing == EmptyView {
    public init(title: String? = nil, alignment: TitleAlignment = .center) {
        self.init(title: title, alignment: alignment, leading: { EmptyView() }, trailing: { EmptyView() })
    }
}

extension DSTopNavigationBar where Leading == EmptyView {
    public init(
        title: String? = nil,
        alignment: TitleAlignment = .center,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.init(title: title, alignment: alignment, leading: { EmptyView() }, trailing: trailing)
    }
}

extension DSTopNavigationBar where Trailing == EmptyView {
    public init(
        title: String? = nil,
        alignment: TitleAlignment = .center,
        @ViewBuilder leading: () -> Leading
    ) {
        self.init(title: title, alignment: alignment, leading: leading, trailing: { EmptyView() })
    }
}

public struct DSBackButton: View {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .foregroundStyle(DesignSystem.Color.white)
        }
    }
}

public struct DSNavigationLogo: View {
    public init() {}

    public var body: some View {
        Text("MOMOGO")
            .momogoTypography(.lgSemistrong)
            .foregroundStyle(DesignSystem.Color.primary500)
    }
}
