import SwiftUI

public struct DSModal: View {
    private let title: String
    private let description: String?
    private let primaryTitle: String
    private let primaryAction: () -> Void
    private let secondaryTitle: String?
    private let secondaryAction: (() -> Void)?

    public init(
        title: String,
        description: String? = nil,
        primaryTitle: String,
        primaryAction: @escaping () -> Void,
        secondaryTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.primaryTitle = primaryTitle
        self.primaryAction = primaryAction
        self.secondaryTitle = secondaryTitle
        self.secondaryAction = secondaryAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .momogoTypography(.xlSemistrong)
                .foregroundStyle(DesignSystem.Color.white)
            if let description {
                Text(description)
                    .momogoTypography(.mdMedium)
                    .foregroundStyle(DesignSystem.Color.gray300)
            }
            HStack(spacing: 8) {
                if let secondaryTitle, let secondaryAction {
                    Button(secondaryTitle, action: secondaryAction)
                        .buttonStyle(.momogoButton(kind: .outlined, tone: .gray))
                }
                Button(primaryTitle, action: primaryAction)
                    .buttonStyle(.momogoButton(kind: .solid, tone: .primary))
            }
            .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.gray800)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r20))
        .momogoShadow()
    }
}

extension View {
    public func momogoModalOverlay(isPresented: Binding<Bool>, modal: @escaping () -> DSModal) -> some View {
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
