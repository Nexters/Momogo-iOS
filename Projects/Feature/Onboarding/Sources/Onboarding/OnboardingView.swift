import SwiftUI

import SwiftUINavigation

public struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    public init(viewModel: OnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            LoginView(viewModel: viewModel)
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(item: $viewModel.destination.nickname) { nicknameViewModel in
                    NicknameView(viewModel: nicknameViewModel)
                }
        }
    }
}
