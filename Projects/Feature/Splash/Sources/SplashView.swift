import SwiftUI

import DesignSystem

public struct SplashView: View {
    struct Constants {
        let logoAccessibilityLabel = "모모고"
        let logoWidth: CGFloat = 175
        let logoHeight: CGFloat = 48
    }

    private let constants = Constants()

    @State private var viewModel: SplashViewModel

    public init(viewModel: SplashViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        VStack {
            Image(asset: DesignSystemAsset.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: constants.logoWidth, height: constants.logoHeight)
                .accessibilityLabel(constants.logoAccessibilityLabel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
        .task {
            await viewModel.start()
        }
    }
}
