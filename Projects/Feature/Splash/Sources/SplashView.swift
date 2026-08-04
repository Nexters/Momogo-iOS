import SwiftUI

import DesignSystem

public struct SplashView: View {
    @State private var viewModel: SplashViewModel

    public init(viewModel: SplashViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        VStack {
            Image(asset: DesignSystemAsset.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 175, height: 48)
                .accessibilityLabel("모모고")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
        .task {
            await viewModel.start()
        }
    }
}
