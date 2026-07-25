import SwiftUI

public struct DSBottomSheet<Content: View>: View {
    public enum HeaderAlignment {
        case center
        case left
    }

    private let title: String?
    private let headerAlignment: HeaderAlignment
    private let onClose: (() -> Void)?
    private let isLoading: Bool
    private let content: Content

    public init(
        title: String? = nil,
        headerAlignment: HeaderAlignment = .center,
        onClose: (() -> Void)? = nil,
        isLoading: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.headerAlignment = headerAlignment
        self.onClose = onClose
        self.isLoading = isLoading
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 16) {
            if let title {
                header(title: title)
            }

            if isLoading {
                ProgressView()
                    .tint(DesignSystem.Color.primary500)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
            } else {
                content
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Color.gray900)
        .clipShape(
            .rect(
                topLeadingRadius: DesignSystem.Radius.r16,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: DesignSystem.Radius.r16
            )
        )
        .momogoShadow()
    }

    private func header(title: String) -> some View {
        ZStack {
            if headerAlignment == .center {
                Text(title)
                    .momogoTypography(.xlSemistrong)
                    .foregroundStyle(DesignSystem.Color.gray50)
            }
            HStack {
                if headerAlignment == .left {
                    Text(title)
                        .momogoTypography(.xlSemistrong)
                        .foregroundStyle(DesignSystem.Color.gray50)
                }
                Spacer()
                if let onClose {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .foregroundStyle(DesignSystem.Color.gray300)
                    }
                }
            }
        }
    }
}

public struct DSBottomSheetAtom: View {
    public enum State {
        case activate
        case deactivate
    }

    private let title: String
    private let state: State

    public init(_ title: String, state: State = .activate) {
        self.title = title
        self.state = state
    }

    public var body: some View {
        Text(title)
            .momogoTypography(state == .activate ? .mdSemistrong : .mdMedium)
            .foregroundStyle(state == .activate ? DesignSystem.Color.gray50 : DesignSystem.Color.gray600)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 15)
            .background(state == .activate ? Color.white.opacity(0.04) : .clear)
            .clipShape(Capsule())
    }
}

public extension View {
    func momogoBottomSheetOverlay(
        isPresented: Binding<Bool>,
        @ViewBuilder sheet: @escaping () -> DSBottomSheet<some View>
    ) -> some View {
        overlay(alignment: .bottom) {
            if isPresented.wrappedValue {
                ZStack(alignment: .bottom) {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture { isPresented.wrappedValue = false }
                    sheet()
                }
                .transition(.move(edge: .bottom))
            }
        }
    }
}
