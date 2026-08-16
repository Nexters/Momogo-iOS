import SwiftUI

public struct DSModal: View {
    private let title: String
    private let description: String?
    private let primaryTitle: String
    private let primaryAction: () -> Void
    private let secondaryTitle: String?
    private let secondaryAction: (() -> Void)?
    private let onClose: (() -> Void)?

    public init(
        title: String,
        description: String? = nil,
        primaryTitle: String,
        primaryAction: @escaping () -> Void,
        secondaryTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.primaryTitle = primaryTitle
        self.primaryAction = primaryAction
        self.secondaryTitle = secondaryTitle
        self.secondaryAction = secondaryAction
        self.onClose = onClose
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            // Figma 실측: Wrap(title+description, gap 8) ↔ Button, gap 24.
            VStack(alignment: .center, spacing: 24) {
                VStack(alignment: .center, spacing: 8) {
                    Text(title)
                        .momogoTypography(.xlSemistrong)
                        .foregroundStyle(DesignSystem.Color.gray50)
                    if let description {
                        Text(description)
                            .momogoMultilineTypography(.mdMedium)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(DesignSystem.Color.gray300)
                    }
                }
                HStack(spacing: 8) {
                    if let secondaryTitle, let secondaryAction {
                        Button(secondaryTitle, action: secondaryAction)
                            .buttonStyle(.momogoButton(kind: .outlined, tone: .gray, isFullWidth: true))
                        Button(primaryTitle, action: primaryAction)
                            .buttonStyle(.momogoButton(kind: .solid, tone: .primary, isFullWidth: true))
                    } else {
                        Button(primaryTitle, action: primaryAction)
                            .buttonStyle(.momogoButton(kind: .solid, tone: .primary, size: .large, isFullWidth: true))
                    }
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .center)

            if let onClose {
                Button(action: onClose) {
                    Image(asset: DesignSystemAsset.x)
                        .foregroundStyle(DesignSystem.Color.gray300)
                }
                .padding(16)
            }
        }
        .background(DesignSystem.Color.gray900)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r24))
        .momogoShadow()
    }
}

public extension View {
    func momogoModalOverlay(isPresented: Binding<Bool>, modal: @escaping () -> DSModal) -> some View {
        overlay {
            if isPresented.wrappedValue {
                ZStack {
                    Color.black.opacity(0.8).ignoresSafeArea()
                    modal().padding(24)
                }
                .transition(.opacity)
            }
        }
    }
}
