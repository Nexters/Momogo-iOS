import SwiftUI

public struct OnboardingView: View {
    @State private var path: [OnboardingRoute] = []

    public init() {}

    public var body: some View {
        NavigationStack(path: $path) {
            NicknameView(onNext: { path.append(.groupSelect) })
                .navigationDestination(for: OnboardingRoute.self) { route in
                    switch route {
                    case .groupSelect:
                        GroupSelectView(
                            onCreateGroup: { path.append(.groupName) },
                            onJoinWithCode: {}
                        )

                    case .groupName:
                        GroupNameView(onCreateGroup: { path.append(.inviteShare) })

                    case .inviteShare:
                        InviteShareView(onGoToMain: {})
                    }
                }
        }
    }
}
