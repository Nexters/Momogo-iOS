import SwiftUI

public struct DSBottomSheet<Content: View>: View {
    private let title: String?
    private let onClose: (() -> Void)?
    private let content: Content

    public init(
        title: String? = nil,
        onClose: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.onClose = onClose
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(DesignSystem.Color.gray600)
                .frame(width: 36, height: 4)
                .padding(.top, 8)

            if let title {
                HStack {
                    Text(title)
                        .momogoTypography(.lgSemistrong)
                        .foregroundStyle(DesignSystem.Color.white)
                    Spacer()
                    if let onClose {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .foregroundStyle(DesignSystem.Color.gray300)
                        }
                    }
                }
            }

            content
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Color.gray800)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r20))
        .momogoShadow()
    }
}

extension View {
    public func momogoBottomSheetOverlay<SheetContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder sheet: @escaping () -> DSBottomSheet<SheetContent>
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
