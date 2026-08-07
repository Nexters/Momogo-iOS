import SwiftUI

import DesignSystem

public struct SplashView: View {
    private struct Constants {
        static let logoSize = CGSize(width: 175, height: 48)
        static let logoAccessibilityLabel = "모모고"
    }

    @State private var viewModel: SplashViewModel

    public init(viewModel: SplashViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        VStack {
            Image(asset: DesignSystemAsset.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.logoSize.width, height: Constants.logoSize.height)
                .accessibilityLabel(Constants.logoAccessibilityLabel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
        .task {
            await viewModel.start()
        }
    }
}
