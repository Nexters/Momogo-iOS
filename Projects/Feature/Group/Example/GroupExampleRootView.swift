import SwiftUI

import FeatureGroup

struct GroupExampleRootView: View {
    @State private var showCreate = false
    @State private var showJoin = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Button("그룹 만들기") {
                    showCreate = true
                }

                Button("초대코드로 참여하기") {
                    showJoin = true
                }
            }
            .navigationDestination(isPresented: $showCreate) {
                GroupNameView(viewModel: GroupNameViewModel(onFinish: {}))
            }
            .navigationDestination(isPresented: $showJoin) {
                InviteCodeInputView(viewModel: InviteCodeInputViewModel(onFinish: {}))
            }
        }
    }
}
