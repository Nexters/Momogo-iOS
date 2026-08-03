import SwiftUI

import DesignSystem

public struct SplashView: View {
    @State private var viewModel: SplashViewModel

    public init(viewModel: SplashViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        VStack {
            Text("Momogo")
                .momogoTypography(.heading32)
                .foregroundStyle(DesignSystem.Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.gray950.ignoresSafeArea())
        .task {
            await viewModel.start()
        }
    }
}
